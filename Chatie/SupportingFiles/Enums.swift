//
//  Enums.swift
//  Chatie
//
//  Created by Rdm on 23/04/2022.
//

import UIKit

enum Alert {
    
    static func existingEmailAlert(on vc: UIViewController) {
        let alert = UIAlertController(title: "Email address error",
                                      message: "The email address is already in use by another account."
                                      ,
                                      preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK",
                                   style: .destructive,
                                   handler: nil)
        alert.addAction(action)
        vc.present(alert, animated: true, completion: nil)
    }
    
    static func registrationErrorAlert(on vc: UIViewController) {
        let alert = UIAlertController(title: "Registration error",
                                      message: "Password must contain 6 and more characters. Check if any fields are empty too and fill them."
                                      ,
                                      preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK",
                                   style: .destructive,
                                   handler: nil)
        alert.addAction(action)
        vc.present(alert, animated: true, completion: nil)
    }
    
    static func userLoginErrorAlert(on vc: UIViewController) {
        let alert = UIAlertController(title: "Login error",
                                      message: "Incorrect login or password",
                                      preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK",
                                   style: .destructive,
                                   handler: nil)
        alert.addAction(action)
        vc.present(alert, animated: true, completion: nil)
    }
}

enum Color {
    
    static let chatieGreen = UIColor(r: 50, g: 180, b: 80)
    
}
