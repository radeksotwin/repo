//
//  Extensions.swift
//  TaskerCoreData
//
//  Created by Rdm on 19/11/2020.
//

import Foundation
import UIKit

extension NSNotification {
    static let keyboardWillShow = UIResponder.keyboardWillShowNotification
    static let keyboardWillHide = UIResponder.keyboardWillHideNotification
}

extension UIViewController {
    func setBackagroundImage(string: String) {
        let backgroundImage = UIImage(imageLiteralResourceName: string)
        let backgroundImageView = UIImageView(image: backgroundImage)
        backgroundImageView.contentMode = .scaleAspectFit
        backgroundImageView.frame = self.view.frame
        self.view.insertSubview(backgroundImageView, at: 0)
    }
}

extension String {
    func integerToPriorityInRomanNumeral(integer: Int) -> String {
        var priority = String()
        let priorityMap: [Int:String] = [1:"I", 2:"II", 3: "III", 4:"IV", 5:"V"]
        priority = priorityMap[integer] ?? "I"
        return priority
    }
}

extension UIDatePicker {
    func shake() {
        let shake = CABasicAnimation(keyPath: "position")
        
        shake.duration = 0.17
        shake.repeatCount = 1.7
        shake.autoreverses = true
        
        let fromPoint = CGPoint(x: center.x - 7, y: center.y)
        let fromValue = NSValue(cgPoint: fromPoint)
        let toPoint = CGPoint(x: center.x + 5, y: center.y)
        let toValue = NSValue(cgPoint: toPoint)
        
        shake.fromValue = fromValue
        shake.toValue = toValue
        layer.add(shake, forKey: nil)
    }
}
extension Date {
    
    static func fullDateString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM YYYY"
        return formatter.string(from: date)
    }
    
    static func convertDateToHourAndMinutes(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    static func convertDateToDateString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM YYYY"
        
        return formatter.string(from: date)
    }
    
    static func converDateToFullDayOfWeekString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        
        return formatter.string(from: date)
    }
    
    static func converDateToShortString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/YYYY"
        
        return formatter.string(from: date)
    }
    
    static func wasInPast(date: Date) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/YYYY"
        let dateAString = formatter.string(from: date)
        let dateBString = formatter.string(from: Date())
        let a = dateAString.split(separator: "/")
        guard let dayA = Int(a[0]) else { return false }
        guard let monthA = Int(a[1]) else { return false }
        guard let yearA = Int(a[2]) else { return false }
        
        let b = dateBString.split(separator: "/")
        guard let dayB = Int(b[0]) else { return false }
        guard let monthB = Int(b[1]) else { return false }
        guard let yearB = Int(b[2]) else { return false }
        
        if yearA == yearB {
            if monthA == monthB {
                if dayA == dayB {
                    return false
                } else if dayA > dayB {
                    return false
                } else {
                    return true
                }
            } else if monthA > monthB {
                return false
            } else {
                return true
            }
        } else if yearA > yearB {
            return false
        } else {
            return true
        }
    }
    
    static func isToday(date: Date) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/YYYY"
        let dateAString = formatter.string(from: date)
        let dateBString = formatter.string(from: Date())
        let a = dateAString.split(separator: "/")
        guard let dayA = Int(a[0]) else { return false }
        guard let monthA = Int(a[1]) else { return false }
        guard let yearA = Int(a[2]) else { return false }
        
        let b = dateBString.split(separator: "/")
        guard let dayB = Int(b[0]) else { return false }
        guard let monthB = Int(b[1]) else { return false }
        guard let yearB = Int(b[2]) else { return false }
        
        return dayA == dayB && monthA == monthB && yearA == yearB ? true : false
    }
    
    static func isTomorrow(date: Date) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/YYYY"
        let dateAString = formatter.string(from: date)
        let dateBString = formatter.string(from: Date())
        let a = dateAString.split(separator: "/")
        guard let dayA = Int(a[0]) else { return false }
        guard let monthA = Int(a[1]) else { return false }
        guard let yearA = Int(a[2]) else { return false }
        
        let b = dateBString.split(separator: "/")
        guard let dayB = Int(b[0]) else { return false }
        guard let monthB = Int(b[1]) else { return false }
        guard let yearB = Int(b[2]) else { return false }
        
        return dayA == dayB + 1 && monthA == monthB && yearA == yearB ? true : false
    }
    
    static func isInUpcoming7days(date: Date) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/YYYY"
        let dateAString = formatter.string(from: date)
        let dateBString = formatter.string(from: Date())
        let a = dateAString.split(separator: "/")
        guard let dayA = Int(a[0]) else { return false }
        guard let monthA = Int(a[1]) else { return false }
        guard let yearA = Int(a[2]) else { return false }
        
        let b = dateBString.split(separator: "/")
        guard let dayB = Int(b[0]) else { return false }
        guard let monthB = Int(b[1]) else { return false }
        guard let yearB = Int(b[2]) else { return false }
        
        return dayA <= dayB + 7 && dayA > dayB + 1 && monthA == monthB && yearA == yearB ? true : false
    }
}





