//
//  MainTabBarController.swift
//  Chatie
//
//  Created by Rdm on 23/04/2022.
//

import Foundation
import UIKit
import FirebaseAuth
import FBSDKLoginKit


class MainTabBarController: UITabBarController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTabBarController()
        setupBarAppearance()
     
        print("Current Access Token:", AccessToken.current)
        print("Current Database User:", FirebaseAuth.Auth.auth().currentUser)
    }
    
    // MainTabBar's controller contentView is already in view hierarchy, so it's possible to use validateAuth() method
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        print("Current Access Token:", AccessToken.current)
        print("Current Database User:", FirebaseAuth.Auth.auth().currentUser)
        
        validateAuth()
    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func validateAuth() {
        if FirebaseAuth.Auth.auth().currentUser == nil, AccessToken.current == nil {
            let vc = LoginViewController()
            let nc = UINavigationController(rootViewController: vc)
            nc.modalPresentationStyle = .fullScreen
            present(nc, animated: false, completion: nil)
        }
    }

    func setupTabBarController() {
        
        let settingsVC = ProfileViewController()
        let conversationsVC = ConverastionsViewController()
        
        let firstItem = addNavigationController(with: conversationsVC, title: "Conversations", image: UIImage(systemName: "message")!)
        let secondItem = addNavigationController(with: settingsVC, title: "Profile", image: UIImage(systemName: "person.crop.square")!)
        
        viewControllers = [firstItem, secondItem]
    }
    
    fileprivate func setupBarAppearance() {
        
        let attributes = [NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font : UIFont.systemFont(ofSize: 32, weight: .semibold)]
        let tabBarAppearance = UITabBarAppearance()
        let navigationBarAppearance = UINavigationBarAppearance()
        
        tabBarAppearance.configureWithOpaqueBackground()
        tabBar.standardAppearance = tabBarAppearance
        tabBar.scrollEdgeAppearance = tabBarAppearance
        tabBar.tintColor = .black

        UINavigationBar.appearance().prefersLargeTitles = true
        UINavigationBar.appearance().standardAppearance = navigationBarAppearance
        navigationBarAppearance.largeTitleTextAttributes = attributes
        
    }
    
    fileprivate func addNavigationController(with rootVc: UIViewController, title: String, image: UIImage) -> UINavigationController {
        
        let navController = UINavigationController(rootViewController: rootVc)
        navController.title = title
        navController.tabBarItem.image = image
        return navController
        
    }
}
