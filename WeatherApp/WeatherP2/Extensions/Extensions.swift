//
//  Extensions.swift
//  WeatherP2
//
//  Created by Rdm on 09/11/2020.
//
import UIKit

extension Date {
    
   static func timeIntervalToFullDayOfWeek(duration: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: duration)
        let formatter = DateFormatter()
        
        formatter.dateFormat = "EEEE"
        
        return formatter.string(from: date).capitalized
    }
    
    static func timeIntervalToHourAndMinute(duration: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: duration)
        let formatter = DateFormatter()
        
        formatter.dateFormat = "HH:MM"
        
        return formatter.string(from: date).capitalized
    }
    
    static func timeIntervalToFullDate(duration: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: duration)
        let formatter = DateFormatter()
        
        formatter.dateFormat = "dd MMMM YYYY"
        
        return formatter.string(from: date)
    }
    
}

extension UIViewController {
    
    func setBackagroundImage(string: String) {
        let backgroundImage = UIImage(imageLiteralResourceName: string)
        let backgroundImageView = UIImageView(image: backgroundImage)
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.frame = self.view.frame
        self.view.insertSubview(backgroundImageView, at: 0)
        
    }
    
}
