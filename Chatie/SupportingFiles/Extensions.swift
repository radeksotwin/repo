//
//  Extensions.swift
//  Chatie
//
//  Created by Rdm on 23/04/2022.
//

import UIKit


extension UIColor {
    
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
    
}

extension UIView {

    func shake() {
        let shake = CABasicAnimation(keyPath: "position")
        
        shake.duration = 1.5
        shake.repeatCount = 3.3
        shake.speed = 6
        shake.autoreverses = true
        
        let fromPoint = CGPoint(x: center.x - 4, y: center.y - 2)
        let fromValue = NSValue(cgPoint: fromPoint)
        let toPoint = CGPoint(x: center.x + 3, y: center.y + 1)
        let toValue = NSValue(cgPoint: toPoint)
        
        shake.fromValue = fromValue
        shake.toValue = toValue
        layer.add(shake, forKey: nil)
    }
}

extension UINavigationBar {
    func transparentNavigationBar() {
        setBackgroundImage(UIImage(), for: .default)
        shadowImage = UIImage()
        isTranslucent = true
    }
}

extension Notification.Name {
    /// Notigication sent when user logs in
    static let didLogInNotification = Notification.Name("didLoginNotification")
}

extension Date {
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.locale = .current // Locale(identifier: "en_US")
        formatter.dateFormat = "MM-dd-yyyy HH:mm" /// Notice that all date objects related with database methods must have the same date format to proper message listening.
        return formatter
    }()
    
    func getFormattedDate(format: String) -> String {
        let dateformat = DateFormatter()
        dateformat.dateFormat = format
        return dateformat.string(from: self)
    }
}
