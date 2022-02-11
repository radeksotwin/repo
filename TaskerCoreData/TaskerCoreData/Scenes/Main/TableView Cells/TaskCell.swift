//
//  TaskCell.swift
//  TaskerCoreData
//
//  Created by Rdm on 20/11/2020.
//

import Foundation
import UIKit


@IBDesignable
class TaskCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var hourLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var priorityLabel: UILabel!
    @IBOutlet weak var colorLabel: UILabel!
    
    var task: Task?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        radiusSetup()
        print(self.contentView.frame)
    }
    
    func radiusSetup() {
        layer.masksToBounds = false
        layer.shadowPath = UIBezierPath(rect: self.contentView.frame).cgPath
        layer.shadowOffset = CGSize(width: 20, height: 30)
        layer.shadowRadius = 30
        layer.shadowOpacity = 0.6
        layer.shadowColor = UIColor.black.cgColor
    }
    
    func setupView() {
        titleLabel.text = task?.title
        dateLabel.text = Date.converDateToShortString(date: (task?.date)!)
        hourLabel.text = Date.convertDateToHourAndMinutes(date: (task?.time)!)
        subtitleLabel.text = task?.subtitle
        priorityLabel.text = integerToPriorityInRomanNumeral(integer: task!.priority)
        colorLabel.backgroundColor = Constants.colors[Int(task!.colorIndex)]
        
        if task?.taskDone == true {
            let attributeTitle: NSMutableAttributedString =  NSMutableAttributedString(string: task!.title)
            attributeTitle.addAttribute(.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeTitle.length))

            let attributeSubtitle: NSMutableAttributedString =  NSMutableAttributedString(string: task!.subtitle)
            attributeSubtitle.addAttribute(.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeSubtitle.length))
            
            titleLabel.attributedText = attributeTitle
            subtitleLabel.attributedText = attributeSubtitle
        } else {
            let attributeTitle: NSMutableAttributedString =  NSMutableAttributedString(string: task!.title)
            attributeTitle.addAttribute(.strikethroughStyle, value: 0, range: NSMakeRange(0, attributeTitle.length))
            
            let attributeSubtitle: NSMutableAttributedString =  NSMutableAttributedString(string: task!.subtitle)
            attributeSubtitle.addAttribute(.strikethroughStyle, value: 0, range: NSMakeRange(0, attributeSubtitle.length))
            
            titleLabel.attributedText = attributeTitle
            subtitleLabel.attributedText = attributeSubtitle
        }
    }
    
    func integerToPriorityInRomanNumeral(integer: Int16) -> String {
        switch integer {
        case 0: return "I"
        case 1: return "II"
        case 2: return "III"
        default: return "I"
        }
    }
    
    @IBInspectable
    var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable
    var shadowRadius: CGFloat = 0 {
        didSet {
            layer.shadowRadius = shadowRadius
            
        }
    }
}
