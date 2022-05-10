//
//  AppDelegate.swift
//  Chatie
//
//  Created by Rdm on 14/04/2022.
//

import UIKit
import FBSDKCoreKit
import Firebase
import GoogleSignIn

// MARK: To fix/refactor/create:

/// Code documentation

// To add:
/// - Successfull registration process Alert
/// - Deleting whole conversation recod when both users will delete their conversation with ceratin user.
/// - After deleting conversation, ask if user want to reintroduce/recover old messages or start a new conversation
/// - ConversationsVC:  Create an indicator of message sender CREATED
/// - ConversationsVC: Create an indicatior of the newest message
/// - LoginVC UI refactor: "Choose profile picture alert"
/// - Change convo index to distinguish the newest conversation
/// - Alerts to error cases - make them more specific

// To fix:
/// - Database: duplicating users records in "users" node during the signing in process. FIXED -> Extra database method - Check if user exist - snapshot.exists()
/// - Database: overriding users node by signing with Facebook process  FIXED -> Extra database method - Check if user exist - snapshot.exists()
/// - Chat VC UI fix: refresh collection view after message is sent, clear message field after message sent
/// - LoginVC UI refactor: Main stackview missing constraints, animation fix
/// - LoginVC UI refactor: Google button layout,
/// - ConversationsVC: conversations array count changing, indexOutOfRange, reloading rows FIXED ->  TableView begin, end updates, reload rows from cellForRowAt method.
/// - Physical device bug - Messages from physical device are not displayed in ChatVC on simulator FIXED -> Date of sent messages must be the same in database
/// - Darkmode - Font color, ChatVC title visible on physical device
///
/// -
///
/// * To learn: working with XCode memory graph


@main
class AppDelegate: UIResponder, UIApplicationDelegate {


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FirebaseApp.configure()
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        GIDSignIn.sharedInstance()?.clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        ApplicationDelegate.shared.application(app, open: url, sourceApplication: UIApplication.OpenURLOptionsKey.sourceApplication as? String, annotation: UIApplication.OpenURLOptionsKey.annotation)
        
        return GIDSignIn.sharedInstance().handle(url, sourceApplication: "", annotation: nil)
    }
    
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

extension AppDelegate: GIDSignInDelegate {
    
    // Reason that this method is calling from AppDelegate?
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        guard error == nil else {
            if let error = error {
                print("Failed to sign in with Google, error message:", error)
            }
            return
        }
        
        guard let authentication = user.authentication else {
            print("Missing auth object of google user")
            return
        }
        
        guard let user = user else {
            print("User is not found")
            return
        }
        
        print("Did signed in by Google: \(user)")
        
        guard let email = user.profile.email,
              let firstName = user.profile.name,
              let lastName = user.profile.givenName else {
                  return
              }
        
//        UserDefaults.standard.setValue(<#T##value: Any?##Any?#>, forKey: <#T##String#>)
        
        UserDefaults.standard.set(email, forKey: "email")
        UserDefaults.standard.set("\(firstName) \(lastName)", forKey: "name")
        
//        let chatUser = ChatAppUser(firstName: firstName, lastName: lastName, emailAddress: email)
//
//        DatabaseManager.shared.insertUser(with: chatUser, completion: { success in
//            if success {
//                if user.profile.hasImage {
//                    guard let url = user.profile.imageURL(withDimension: 200) else {
//                        return
//                    }
//
//                    URLSession.shared.dataTask(with: url, completionHandler: { data, _ , error in
//                        guard let data = data, error == nil else {
//                            print("Failed to download Facebook profile picture")
//                            return
//                        }
//
//                        let filename = chatUser.profilePictureFileName
//
//                        StorageManager.shared.uploadProfilePicture(with: data, fileName: filename, completion: { result in
//                            switch result {
//                            case .success(let downloadURL):
//                                UserDefaults.standard.set(downloadURL, forKey: "profile_picture_url")
//                            case .failure(let error):
//                                print("Storage manager error: \(error)")
//                            }
//                        })
//                    }).resume()
//                }
//            }
//        })
//
//        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
//                                                       accessToken: authentication.accessToken)
//
//        FirebaseAuth.Auth.auth().signIn(with: credential, completion: { [weak self] authResult, error in
//            guard authResult != nil, error == nil else {
//                if let error = error {
//                    print("Failed to sign in with Google:", error)
//                }
//                return
//            }
//
//            guard let result = authResult else {
//                return
//            }
//            print("Successfully signed with Google credential")
//            NotificationCenter.default.post(name: .didLogInNotification, object: nil)
//        })
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
          
    }
    
    
    
}

