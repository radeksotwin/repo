
//  DatabaseManager.swift
//  Chatie
//
//  Created by Rdm on 23/04/2022.


import FirebaseDatabase
import MessageKit
import UIKit
import CoreLocation

// Database manager object that provides several Firebase database read/write functions

final class DatabaseManager {

    /// `Shared instance of a class` - singleton object
    public static let shared = DatabaseManager()

    private let database = Database.database().reference()

    static func safeEmail(emailAddress: String) -> String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
}


/// Notice that reading something from Firebase is more CPU and memory consumption - reason to cache values with UserDefaults

// MARK: Account management

extension DatabaseManager {

    public func test() {
        database.child("Test").setValue("TestValue")
    }

    /// Checking if user exists for given email
    public func checkIfUsersExists(for email: String, completion: @escaping (Bool) -> Void) {
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)

        database.child(safeEmail).observeSingleEvent(of: .value, with: { snapshot in
            guard snapshot.exists() else {
                completion(false)
                return
            }
            completion(true)
        })
    }

    public func checkIfConversationExists(with conversationId: String, completion: @escaping (Bool) -> Void) {
        database.child("\(conversationId)").observeSingleEvent(of: .value, with: { snapshot in
            guard snapshot.exists() else {
                completion(false)
                return
            }
            completion(true)
        })
    }

    
    /// Checking if conversation exists in recipient's user node
    public func isConversationExists(with targetRecipientEmail: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let senderEmail = UserDefaults.standard.value(forKey: "email") as? String else { return }
        let safeRecipientEmail = DatabaseManager.safeEmail(emailAddress: targetRecipientEmail)
        let safeSenderEmail = DatabaseManager.safeEmail(emailAddress: senderEmail)

        print("SAFE RECPNT EMAIL:", safeRecipientEmail)
        print("DB METHOD CALLED")
        
        database.child("\(safeRecipientEmail)/conversations").observeSingleEvent(of: .value, with: { snapshot in
            guard let collection = snapshot.value as? [[String:Any]] else {
                completion(.failure(DatabaseError.userHasNoConversations))
                return
            }

            if let conversation = collection.first(where: {
                guard let targetSenderEmail = $0["other_user_email"] as? String else {
                    completion(.failure(DatabaseError.failedToFetchUsers))
                    return false
                }
                return safeSenderEmail == targetSenderEmail
            }) {
                guard let id = conversation["id"] as? String else {
                    completion(.failure(DatabaseError.failedToFetchUsers))
                    return
                }
                print("Conversation ID: \(id)")
                completion(.success(id))
            } else {
                completion(.failure(DatabaseError.conversationNotExists))
                print("There is no conversation with that user - pushing ChatViewController with new convo")
            }
        })
    }

    /// Inserting a new user to database
    public func insertUser(with user: ChatAppUser, completion: @escaping (Bool) -> Void) {
        database.child(user.safeEmail).setValue([
            "first_name": user.firstName,
            "last_name": user.lastName
        ], withCompletionBlock: { [weak self] error, _ in
            guard let me = self else { return }
            guard error == nil else {
                print("Failed to write to database")
                completion(false)
                return
            }

            me.database.child("users").observeSingleEvent(of: .value, with: { snapshot in
                if var usersCollection = snapshot.value as? [[String: String]] {

                    /// Append to user dictionary
                    let newElement = [
                        "name": user.firstName + " " + user.lastName, "email": user.safeEmail
                    ]

                    usersCollection.append(newElement)

                    me.database.child("users").setValue(usersCollection, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        completion(true)
                    })

                }
                else {

                    /// Create that array
                    let newCollection: [[String: String]] = [
                        [
                            "name": user.firstName + " " + user.lastName, "email": user.safeEmail
                        ]
                    ]

                    me.database.child("users").setValue(newCollection, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        print("New Collection created")
                        completion(true)
                    })
                }
            })
        })
    }

    /// Getting the whole list of app users
    public func getAllUsers(completion: @escaping (Result<[[String: String]], Error>) -> Void) {
        database.child("users").observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value as? [[String: String]] else {
                completion(.failure(DatabaseError.failedToFetchUsers))
                return
            }
            completion(.success(value))
        })
    }

    public enum DatabaseError: Error {
        case failedToFetchUsers
        case failedToFetchConversations
        case userHasNoConversations
        case conversationNotExists
        
        public var localizedDescription: String {
            switch self {
            case .failedToFetchUsers:
                return ""
            case .failedToFetchConversations:
                return ""
            case .userHasNoConversations:
                return ""
            case .conversationNotExists:
                return ""
            }
        }
    }

}


// MARK: - Sending messages / conversations

extension DatabaseManager {

    /*
       "convID" {
         "messages": [
           "id": String,
           "type": text, photo, video,
           "content": String,
           "date": Date(),
           "sender_email": String,
           "isRead": true/false
         ]
       }

       conversation => [
        [

          "conversation_id": "convID"
          "other_user_email": ""
          "latest_message": => {
             "date": Date()
             "latest_message": "message"
             "is_read": true/false
          }
        ],
      ]

     latest message ?
     */

    /// Creates a new conversation with target user email and first message sent
    public func createNewConversation(with otherUserEmail: String, name: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {

        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String,
              let currentUserName = UserDefaults.standard.value(forKey: "name") as? String else { return }

        let safeCurrentEmail = DatabaseManager.safeEmail(emailAddress: currentEmail)
        let reference = database.child("\(safeCurrentEmail)")

        reference.observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard var userNode = snapshot.value as? [String : Any] else {
                completion(false)
                print("User not found")
                return
            }

            let messageDate = firstMessage.sentDate
            let dateString = Date.dateFormatter.string(from: messageDate)
            let conversationId = "conversation_\(firstMessage.messageId)"
            var message = ""

            switch firstMessage.kind {

            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }

            let newConversationData: [String: Any] = [
                "id": conversationId,
                "other_user_email": otherUserEmail,
                "name": name,
                "latest_message": [
                    "date": dateString,
                    "message": message,
                    "sender_name": currentUserName,
                    "is_read": false
                ]
            ]

            let recipient_newConversationData: [String: Any] = [
                "id": conversationId,
                "other_user_email": safeCurrentEmail,
                "name": currentUserName,
                "latest_message": [
                    "date": dateString,
                    "message": message,
                    "sender_name": currentUserName,
                    "is_read": false
                ]
            ]

            /// Update recipient conversation node
            self?.database.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value, with: { [weak self] snapshot in
                if var conversations = snapshot.value as? [[String: Any]] {
                    // append
                    conversations.append(recipient_newConversationData)
                    self?.database.child("\(otherUserEmail)/conversations").setValue(conversations)

                } else {
                    // create
                    self?.database.child("\(otherUserEmail)/conversations").setValue([recipient_newConversationData])
                }
            })

            /// Update current user conversations entry
            if var conversations = userNode["conversations"] as? [[String: Any]] {
                // append conversations
                conversations.append(newConversationData)
                userNode["conversations"] = conversations

                reference.setValue(userNode, withCompletionBlock: { [weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    self?.finishCreatingConversation(conversationId: conversationId, name: name, firstMessage: firstMessage, completion: completion)
                })

            } else {
                // create conversations node
                userNode["conversations"] = [
                    newConversationData
                ]

                reference.setValue(userNode, withCompletionBlock: { [weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    completion(true)
                    self?.finishCreatingConversation(conversationId: conversationId, name: name, firstMessage: firstMessage, completion: completion)
                })
            }
        })
    }


    private func finishCreatingConversation(conversationId: String, name: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {

        let messageDate = firstMessage.sentDate
        let dateString = Date.dateFormatter.string(from: messageDate)
        var message = ""

        switch firstMessage.kind {

        case .text(let messageText):
            message = messageText
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }

        /// Notice that the current user email value on key "email" in UserDefaults is overridden every single time when new user is logged in.
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }

        let collectionMessage: [String: Any] = [
            "id": firstMessage.messageId,
            "type": firstMessage.kind.messageKindString,
            "content": message,
            "date": dateString,
            "sender_email": currentUserEmail,
            "isRead": false,
            "name" : name
        ]

        let value: [String : Any] = [
            "messages": [
                collectionMessage
            ]
        ]

        database.child("\(conversationId)").setValue(value, withCompletionBlock: { error, _ in
            guard error == nil else {
                completion(false)
                return
            }
            completion(true)
        })
    }

    /// Fetches all conversations for the user with passed email
    public func getAllConversations(for email: String, completion: @escaping (Result<[Conversation], Error>) -> Void) {

        database.child("\(email)/conversations").observe(.value, with: { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.userHasNoConversations))
                return
            }

            let conversations: [Conversation] = value.compactMap({ dictionary in
                guard let conversationId = dictionary["id"] as? String,
                      let name = dictionary["name"] as? String,
                      let otherUserEmail = dictionary["other_user_email"] as? String,
                      let latestMessage = dictionary["latest_message"] as? [String: Any],
                      let dateSent = latestMessage["date"] as? String,
                      let message = latestMessage["message"] as? String,
                      let senderName = latestMessage["sender_name"] as? String,
                      let isRead = latestMessage["is_read"] as? Bool else {
                          return nil
                      }

                let latestMessageObject = LatestMessage(date: dateSent, text: message, senderName: senderName, isRead: isRead)

                return Conversation(id: conversationId, name: name, otherUserEmail: otherUserEmail, latestMessage: latestMessageObject)

            })
            completion(.success(conversations))
        })
    }

    /// Gets all messages for chosen conversation
    public func getAllMesssagesForConversation(with id: String, completion: @escaping (Result<[Message], Error>) -> Void) {
        database.child("\(id)/messages").observe(.value, with: { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedToFetchConversations))
                return
            }

            let messages: [Message] = value.compactMap({ dictionary in
                guard let messageId = dictionary["id"] as? String,
                      let name = dictionary["name"] as? String,
                      let senderEmail = dictionary["sender_email"] as? String,
                      let dateString = dictionary["date"] as? String,
                      let type = dictionary["type"] as? String,
                      let message = dictionary["content"] as? String,
                      let isRead = dictionary["isRead"] as? Bool,
                      let date = Date.dateFormatter.date(from: dateString)
                else {
                    return nil
                }


                var kind: MessageKind?

                if type == "photo" {
                    guard let imageUrl = URL(string: message),
                          let placeholder = UIImage(systemName: "plus") else { return nil }

                    let media = Media(url: imageUrl, image: nil, placeholderImage: placeholder, size: CGSize(width: 300, height: 300))

                    kind = .photo(media)

                } else if type == "video" {
                    guard let videoUrl = URL(string: message),
                          let placeholder = UIImage(systemName: "film") else { return nil }
                    placeholder.withTintColor(UIColor.black)
                    let media = Media(url: videoUrl, image: nil, placeholderImage: placeholder, size: CGSize(width: 300, height: 300))

                    kind = .video(media)

                } else if type == "location" {
                    let locationComponent = message.components(separatedBy: ",")
                    guard let longitude = Double(locationComponent[0]),
                          let latitude = Double(locationComponent[1]) else { return nil }

                    let location = Location(location: CLLocation(latitude: latitude, longitude: longitude), size: CGSize(width: 300, height: 300))
                    kind = .location(location)

                } else {
                    kind = .text(message)
                }

                guard let finalKind = kind else { return nil }

                let sender = Sender(photoURL: "", senderId: senderEmail, displayName: name)

                return Message(sender: sender, messageId: messageId, sentDate: date, kind: finalKind)

            })
            completion(.success(messages))
        })
    }


    /// Sends a message with target conversation and message
    public func sendMessage(to conversation: String, name: String, otherUserEmail: String, newMessage: Message, completion: @escaping (Bool) -> Void) {

        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            completion(false)
            print("Current email error")
            return
        }
        guard let currentUserName = UserDefaults.standard.value(forKey: "name") as? String else { return }

        print("OUE:", otherUserEmail)

        let safeCurrentUserEmail = DatabaseManager.safeEmail(emailAddress: currentUserEmail)
        let messageDate = newMessage.sentDate
        let dateString = Date.dateFormatter.string(from: messageDate)
        let senderName = newMessage.sender.displayName

        database.child("\(conversation)/messages").observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard let me = self else { return }
            guard var currentMessages = snapshot.value as? [[String : Any]] else {
                completion(false)
                print("currentMessages snapshot error")
                return
            }

            var message = ""

            switch newMessage.kind {

            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(let mediaItem):
                if let targetUrlString = mediaItem.url?.absoluteString {
                    message = targetUrlString
                }
                break
            case .video(let mediaItem):
                if let targetUrlString = mediaItem.url?.absoluteString {
                    message = targetUrlString
                }
                break
            case .location(let locationData):
                let location = locationData.location
                message = "\(location.coordinate.longitude),\(location.coordinate.latitude)"
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }

            /// Notice that the current user email value on key "email" in UserDefaults is overridden every single time when new user is logged in.
            let newMessageEntry: [String: Any] = [
                "id": newMessage.messageId,
                "type": newMessage.kind.messageKindString,
                "content": message,
                "date": dateString,
                "sender_email": currentUserEmail,  // This email must be unsafe due to proper messageCollection display on ChatVC
                "isRead": false,
                "name" : name
            ]

            let updatedMessage: [String: Any] = [
                "date": dateString,
                "sender_name": currentUserName,
                "is_read": false,
                "message": message
            ]

            currentMessages.append(newMessageEntry)

            me.database.child("\(conversation)/messages").setValue(currentMessages, withCompletionBlock: { error,_ in
                guard error == nil else {
                    completion(false)
                    print("Messages array update fail")
                    return
                }

                // To refactor?:
                /// Update latest message in recipient's conversation or create new conversation data if there is no conversation
                me.database.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value, with: { snapshot in

                    var databaseEntryConversations = [[String:Any]]()

                    if var userConversations = snapshot.value as? [[String:Any]] {
                        /// Update latest message in recipient's conversation
                        me.updateLatestMessageFor(conversation: conversation, name: currentUserName, otherUserEmail: safeCurrentUserEmail, email: otherUserEmail, with: updatedMessage, completion: completion)

                    } else {

                        let newConversationData: [String: Any] = [
                            "id": conversation,
                            "other_user_email": safeCurrentUserEmail,
                            "name": currentUserName,
                            "latest_message": updatedMessage
                        ]

                        databaseEntryConversations = [
                                newConversationData
                        ]

                        me.database.child("\(otherUserEmail)/conversations").setValue(databaseEntryConversations, withCompletionBlock: { error,_ in
                            guard error == nil else {
                                print("Error appending new message data to conversation")
                                completion(false)
                                return
                            }
                            completion(true)
                        })
                        print("Creating new conversation data")
                    }
                })

                /// Update latest message in current user's conversation or create new conversation data if there is no conversation
                me.database.child("\(safeCurrentUserEmail)/conversations").observeSingleEvent(of: .value, with: { snapshot in

                    var databaseEntryConversations = [[String:Any]]()

                    if var userConversations = snapshot.value as? [[String:Any]] {
                        /// Update latest message in current user's conversation
                        me.updateLatestMessageFor(conversation: conversation, name: name, otherUserEmail: otherUserEmail, email: safeCurrentUserEmail, with: updatedMessage, completion: completion)
                    } else {

                        let newConversationData: [String: Any] = [
                            "id": conversation,
                            "other_user_email": otherUserEmail,
                            "name": name,
                            "latest_message": updatedMessage
                        ]

                        databaseEntryConversations = [
                                newConversationData
                        ]

                        me.database.child("\(safeCurrentUserEmail)/conversations").setValue(databaseEntryConversations, withCompletionBlock: { error,_ in
                            guard error == nil else {
                                print("Error appending new message data to conversation")
                                completion(false)
                                return
                            }
                            completion(true)
                        })
                        print("Creating new conversation data")
                    }
                })
            })
        })
    }


    /// Updates latest message in both users nodes
    private func updateLatestMessageFor(conversation: String, name: String, otherUserEmail: String, email: String, with updatedMessage: [String : Any], completion: @escaping (Bool) -> Void) {

        database.child("\(email)/conversations").observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard let me = self else { return }

            guard var userConversations = snapshot.value as? [[String : Any]] else {
                completion(false)
                return
            }

            var targetConversation: [String:Any]?
            var position = 0

            for conversationDictionary in userConversations {
                if let currentId = conversationDictionary["id"] as? String, currentId == conversation {
                    targetConversation = conversationDictionary
                    break
                }
                position += 1
            }

            if var targetConversation = targetConversation {
                targetConversation["latest_message"] = updatedMessage

                userConversations[position] = targetConversation

                me.database.child("\(email)/conversations").setValue(userConversations, withCompletionBlock: { error,_ in
                    guard error == nil else {
                        print("Error appending new message data to conversation")
                        completion(false)
                        return
                    }
                    completion(true)
                })
            } else {

                let newConversationData: [String: Any] = [
                    "id": conversation,
                    "other_user_email": otherUserEmail,
                    "name": name,
                    "latest_message": updatedMessage
                ]

                userConversations.append(newConversationData)

                me.database.child("\(email)/conversations").setValue(userConversations, withCompletionBlock: { error,_ in
                    guard error == nil else {
                        print("Error appending new message data to conversation")
                        completion(false)
                        return
                    }
                    completion(true)
                })
            }
        })
    }


    public func deleteConversation(with conversationId: String, completion: @escaping (Bool) -> Void) {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }

        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        let reference = database.child("\(safeEmail)/conversations")

        print("Deleting conversation with id: \(conversationId)")

        // Get convos for current user
        // delete convo in collection in with target id
        // Reset the conversations for the user in database

        reference.observeSingleEvent(of: .value, with: { snapshot in
            if var conversations = snapshot.value as? [[String:Any]] {
                var positionToRemove = 0
                for conversation in conversations {
                    if let id = conversation["id"] as? String, id == conversationId {
                        print("Found conversation to delete")
                        break
                    }
                    positionToRemove += 1
                }

                conversations.remove(at: positionToRemove)

                reference.setValue(conversations, withCompletionBlock: { error, _ in
                    guard error == nil else {
                        print("Failed to write new conversations array")
                        completion(false)
                        return
                    }
                    print("Conversation successfully deleted")
                    completion(true)
                })
            }
        })
    }
}

extension DatabaseManager {

    public func getUsersData(for path: String, completion: @escaping (Result<Any, Error>) -> Void) {

        database.child("\(path)").observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value else {
                completion(.failure(DatabaseError.failedToFetchUsers))
                return
            }
            completion(.success(value))
        })
    }
}
