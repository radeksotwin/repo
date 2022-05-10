//
//  ChatViewController.swift
//  Chatie
//
//  Created by Rdm on 23/04/2022.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import SDWebImage
import AVFoundation
import AVKit
import CoreLocation

/// Cleaning up...
final class ChatViewController: MessagesViewController, MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    
    private var senderPhotoURL: URL?
    private var otherUserPhotoURL: URL?
    
    public let otherUserEmail: String
    public let conversationId: String?
    public var isNewConversation = false
    
    private var messages = [Message]()
    
    private var selfSender: Sender? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        
        return Sender(photoURL: "", senderId: email, displayName: "Me")
    }
    
    init(id: String, with email: String) {
        self.conversationId = id
        self.otherUserEmail = email
        super.init(nibName: nil, bundle: nil)
        if let conversationId = conversationId {
            listenForMessages(for: conversationId, shouldScrollToBottom: true)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messageInputBar.delegate = self
        setupInputButton()
        view.backgroundColor = .yellow
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        messageInputBar.inputTextView.becomeFirstResponder()
    }
    
    private func setupInputButton() {
        let button = InputBarButtonItem()
        
        button.setSize(CGSize(width: 35, height: 35), animated: false)
        button.setImage(UIImage(systemName: "paperclip"), for: .normal)
        button.tintColor = Color.chatieGreen
        button.onTouchUpInside { [weak self] _ in
            guard let me = self else { return }
            me.presentInputActionSheet()
        }
        
        messageInputBar.setLeftStackViewWidthConstant(to: 30, animated: false)
        messageInputBar.setStackViewItems([button], forStack: .left, animated: false)
    }
    
    private func presentInputActionSheet() {
        
        let actionSheet = UIAlertController(title: "Attach Media", message: "What would you like to attach?", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Photo", style: .default, handler: { [weak self] action in
            self?.presentPhotoInputActionSheet()
        }))
        actionSheet.addAction(UIAlertAction(title: "Video", style: .default, handler: { [weak self] action in
            self?.presentVideoInputActionSheet()
        }))
        actionSheet.addAction(UIAlertAction(title: "Audio", style: .default, handler: { [weak self] action in
            
        }))
        actionSheet.addAction(UIAlertAction(title: "Location", style: .default, handler: { [weak self] action in
            self?.presentLocationPicker()
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { [weak self] action in }))
        present(actionSheet, animated: true)
    }
    
    private func presentLocationPicker() {
        let vc = LocationPickerController(coordinates: nil, isPickable: true)
        vc.navigationItem.largeTitleDisplayMode = .never

        vc.completion = { [weak self] selectedCoordinates in
            
            guard let me = self else { return }
            guard  let conversationId = me.conversationId,
                   let messageId = me.generateMessageId(),
                   let name = me.title,
                   let selfSender = me.selfSender else {
                       return
                   }
            
            let longitude: Double = selectedCoordinates.longitude
            let latitude: Double = selectedCoordinates.latitude
            
            print("longitude: \(longitude), latitude: \(latitude)")
            
            let location = Location(location: CLLocation(latitude: latitude, longitude: longitude), size: .zero)
            let newMessage = Message(sender: selfSender, messageId: messageId, sentDate: Date(), kind: .location(location))
            
            DatabaseManager.shared.sendMessage(to: conversationId, name: name, otherUserEmail: me.otherUserEmail, newMessage: newMessage, completion: { success in
                if success {
                    print("Location message sent")
                } else {
                    print("Failed to send location message")
                }
            })
            
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func presentPhotoInputActionSheet() {
        let actionSheet = UIAlertController(title: "Attach Photo", message: "Where would you like to attach a photo from?", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { [weak self] action in
    
            guard let me = self else { return }
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.allowsEditing = true
            
            me.present(picker, animated: true)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [weak self] action in
            
            guard let me = self else { return }
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            picker.allowsEditing = true
            
            me.present(picker, animated: true)
        }))
    
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { [weak self] action in }))
        present(actionSheet, animated: true)
    }
    
    private func presentVideoInputActionSheet() {
        let actionSheet = UIAlertController(title: "Attach Photo", message: "Where would you like to attach a Video from?", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Library", style: .default, handler: { [weak self] action in
    
            guard let me = self else { return }
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.mediaTypes = ["public.movie"]
            picker.videoQuality = .typeMedium
            picker.delegate = self
            picker.allowsEditing = true
            
            me.present(picker, animated: true)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [weak self] action in
            
            guard let me = self else { return }
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.mediaTypes = ["public.movie"]
            picker.videoQuality = .typeMedium
            picker.delegate = self
            picker.allowsEditing = true
            
            me.present(picker, animated: true)
        }))
    
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { [weak self] action in }))
        present(actionSheet, animated: true)
    }
    
    private func listenForMessages(for id: String, shouldScrollToBottom: Bool) {
        
        DatabaseManager.shared.getAllMesssagesForConversation(with: id, completion: { [weak self] result in
            switch result {
            case .success(let messages):
                guard !messages.isEmpty else {
                    print("Messages array is empty")
                    return
                }
                
                self?.messages = messages
            
                DispatchQueue.main.async {
                    self?.messagesCollectionView.reloadDataAndKeepOffset()
                    if shouldScrollToBottom {
                        self?.messagesCollectionView.scrollToLastItem()
                    }
                }
     
            case .failure(let error):
                print("Error fetching coversation messages: \(error)")
            }
        })
    }
    
    func currentSender() -> SenderType {
        if let sender = selfSender {
            return sender
        }
        fatalError("Self sender is nil, email should be cached")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        guard let message = message as? Message else { return }
        
        switch message.kind {
        case .photo(let mediaItem):
            guard let imageUrl = mediaItem.url else { return }
            
            imageView.sd_setImage(with: imageUrl, completed: nil)
        default:
            break
        }
    }
    
}

extension ChatViewController: MessageCellDelegate {
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
       
        let sender = message.sender
        
        if sender.senderId == selfSender?.senderId {
            if let currentUserImageURL = senderPhotoURL {
                avatarView.sd_setImage(with: currentUserImageURL, completed: nil)
            } else {
                // fetch url
                
                guard let email = UserDefaults.standard.value(forKey: "email") as? String else { return }
                
                let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
                let path = "images/\(safeEmail)_profile_picture.png"
                
                StorageManager.shared.downloadUrl(for: path, completion: { [weak self] result in
                    switch result {
                    case .success(let url):
                        self?.senderPhotoURL = url
                        DispatchQueue.main.async {
                            avatarView.sd_setImage(with: url, completed: nil)
                        }
                    case .failure(let error):
                        print("\(error)")
                    }
                })
            }
        } else {
            if let otherUserPhotoURL = otherUserPhotoURL {
                avatarView.sd_setImage(with: otherUserPhotoURL, completed: nil)
            } else {
                // fetch url
                let email = otherUserEmail
                
                let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
                let path = "images/\(safeEmail)_profile_picture.png"
                
                StorageManager.shared.downloadUrl(for: path, completion: { [weak self] result in
                    switch result {
                    case .success(let url):
                        self?.otherUserPhotoURL = url
                        DispatchQueue.main.async {
                            avatarView.sd_setImage(with: url, completed: nil)
                        }
                    case .failure(let error):
                        print("\(error)")
                    }
                })
            }
        }
    
            
    }
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else { return }
        let message = messages[indexPath.section]
        print("\(indexPath)")
        
        
        switch message.kind {
        case .location(let locationData):
            
            let coordinates = locationData.location.coordinate
            let vc = LocationPickerController(coordinates: coordinates, isPickable: false)
            self.navigationController?.pushViewController(vc, animated: true)
          
        default:
            break
        }
        
    }
    
    func didTapImage(in cell: MessageCollectionViewCell) {

        guard let indexPath = messagesCollectionView.indexPath(for: cell) else { return }
        let message = messages[indexPath.section]
        print("\(indexPath)")
        
        
        switch message.kind {
        case .photo(let mediaItem):
            
            guard let imageUrl = mediaItem.url else { return }
            
            let attributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
            let vc = PhotoViewerViewController(with: imageUrl)

            vc.title = "Photo"
            vc.navigationItem.largeTitleDisplayMode = .never
            vc.navigationController?.navigationBar.titleTextAttributes = attributes
            vc.navigationController?.isNavigationBarHidden = false
            vc.navigationController?.navigationBar.isTranslucent = false
            navigationController?.pushViewController(vc, animated: true)
    
        case .video(let mediaItem):
            guard let videoUrl = mediaItem.url else { return }
            
            let vc = AVPlayerViewController()
            
            vc.player = AVPlayer(url: videoUrl)
            vc.player?.play()
            present(vc, animated: true)
        default:
            break
        }
    }
    
}

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard  let conversationId = conversationId,
               let messageId = generateMessageId(),
               let name = title,
               let selfSender = selfSender else {
                   return
               }
        
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage,
           let imageData = image.pngData() {
        
        let fileName = "photo_message_" + messageId.replacingOccurrences(of: " ", with: "-") + ".png"
        
        StorageManager.shared.uploadMessagePhoto(with: imageData, fileName: fileName, completion: { [weak self] result in
            
            guard let me = self else { return }
            
            switch result {
            case .success(let urlString):
                
                /// Ready to send message - in translation, update the database!
                guard let url = URL(string: urlString), let placeholder = UIImage(systemName: "plus") else { return }
                print("MessagePhoto URL: \(url)")
                let media = Media(url: url, image: nil, placeholderImage: placeholder, size: .zero)
                let newMessage = Message(sender: selfSender, messageId: messageId, sentDate: Date(), kind: .photo(media))
                
                DatabaseManager.shared.sendMessage(to: conversationId, name: name, otherUserEmail: me.otherUserEmail, newMessage: newMessage, completion: { success in
                    if success {
                        print("Photo message sent")
                    } else {
                        print("Failed to send photo message")
                    }
                })
                
                print("Uploaded message photo")
            case .failure(let error):
                print("Message photo upload failed: \(error)")
            }
        })
        
        } else if let videoUrl = info[.mediaURL] as? URL {
            let fileName = "video_message_" + messageId.replacingOccurrences(of: " ", with: "-") + ".mov"
            
            // Upload video
            StorageManager.shared.uploadMessageVideo(with: videoUrl, fileName: fileName, completion: { [weak self] result in
                
                guard let me = self else { return }
                
                switch result {
                case .success(let urlString):
                    
                    /// Ready to send message - in translation, update the database!
                    guard let url = URL(string: urlString), let placeholder = UIImage(systemName: "plus") else { return }
                    print("Uploaded message video URL: \(url)")
                    let media = Media(url: url, image: nil, placeholderImage: placeholder, size: .zero)
                    let newMessage = Message(sender: selfSender, messageId: messageId, sentDate: Date(), kind: .video(media))
                    
                    DatabaseManager.shared.sendMessage(to: conversationId, name: name, otherUserEmail: me.otherUserEmail, newMessage: newMessage, completion: { success in
                        if success {
                            print("Photo message sent")
                        } else {
                            print("Failed to send photo message")
                        }
                    })
                    
                    print("Uploaded message photo")
                case .failure(let error):
                    print("Message photo upload failed: \(error)")
                }
            })
        }
    }
    // Upload image
    
    // Send Message
    
}

extension ChatViewController: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty, let messageId = generateMessageId() else {
             return
        }
        
        let date = Date()
        date.getFormattedDate(format: "MM-dd-yyyy H:mm a")
  
        let message = Message(sender: selfSender as! SenderType, messageId: messageId, sentDate: date, kind: .text(text))
        
        
        if isNewConversation {
            /// Create conversation in database
            DatabaseManager.shared.createNewConversation(with: otherUserEmail ?? "", name: title ?? "User", firstMessage: message, completion: { [weak self] success in
                if success {
                    print("\(self?.title)")
                    self?.isNewConversation = false
                    
                    let newConversationId = "conversation_\(message.messageId)"
                    
                    self?.listenForMessages(for: newConversationId, shouldScrollToBottom: true)
                } else {
                    print("Failed to sent message")
                }
                
            })
        } else {
            /// Append to existing conversation
            guard let id = conversationId, let name = title else { return }
            
            DatabaseManager.shared.sendMessage(to: id, name: name, otherUserEmail: otherUserEmail, newMessage: message, completion: { success in
                if success {
                    print("Message sent")
                } else {
                     print("failed to send")
                }
            })
        }
        inputBar.inputTextView.text = nil
    }
    
    private func generateMessageId() -> String? {
        
        /// date, otherUserEmail, senderEmail, random Int
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        
        let safeCurrentEmail = DatabaseManager.safeEmail(emailAddress: currentUserEmail)
        let dateString = Date.dateFormatter.string(from: Date())
        
        /// Replacing "slash" character to avoid creating new nodes in database "conversation" node
        let safeDate = dateString.replacingOccurrences(of: "/", with: "-")
        safeDate.replacingOccurrences(of: " ", with: "-")
        print(safeDate)
        
        let newIdentifier = "\(safeCurrentEmail)_\(otherUserEmail)_\(safeDate)"
        print("Created messageID: \(newIdentifier)")
        return newIdentifier
    }
    
}
