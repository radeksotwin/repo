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
        
        guard let title = task?.title,
              let date = task?.date,
              let time = task?.time,
              let subtitle = task?.subtitle,
              let priority = task?.priority,
              let color = task?.colorIndex,
              let taskDone = task?.taskDone else {
                  return
              }
        
        titleLabel.text = title
        dateLabel.text = Date.converDateToShortString(date: date)
        hourLabel.text = Date.convertDateToHourAndMinutes(date: time)
        subtitleLabel.text = subtitle
        priorityLabel.text = integerToPriorityInRomanNumeral(integer: priority)
        colorLabel.backgroundColor = Constants.colors[Int(color)]
        
        let dynamicValueForStrikeThrough = taskDone ? 2 : 0
        
        let attributeTitle: NSMutableAttributedString =  NSMutableAttributedString(string: title)
        attributeTitle.addAttribute(.strikethroughStyle, value: dynamicValueForStrikeThrough, range: NSMakeRange(0, attributeTitle.length))

        let attributeSubtitle: NSMutableAttributedString =  NSMutableAttributedString(string: subtitle)
        attributeSubtitle.addAttribute(.strikethroughStyle, value: dynamicValueForStrikeThrough, range: NSMakeRange(0, attributeSubtitle.length))

        titleLabel.attributedText = attributeTitle
        subtitleLabel.attributedText = attributeSubtitle

//        if task?.taskDone == true {
//
//            let attributeTitle: NSMutableAttributedString =  NSMutableAttributedString(string: task!.title)
//            attributeTitle.addAttribute(.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeTitle.length))
//
//            let attributeSubtitle: NSMutableAttributedString =  NSMutableAttributedString(string: task!.subtitle)
//            attributeSubtitle.addAttribute(.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeSubtitle.length))
//
//            titleLabel.attributedText = attributeTitle
//            subtitleLabel.attributedText = attributeSubtitle
//
//
//        } else {
//            let attributeTitle: NSMutableAttributedString =  NSMutableAttributedString(string: task!.title)
//            attributeTitle.addAttribute(.strikethroughStyle, value: 0, range: NSMakeRange(0, attributeTitle.length))
//
//            let attributeSubtitle: NSMutableAttributedString =  NSMutableAttributedString(string: task!.subtitle)
//            attributeSubtitle.addAttribute(.strikethroughStyle, value: 0, range: NSMakeRange(0, attributeSubtitle.length))
//
//            titleLabel.attributedText = attributeTitle
//            subtitleLabel.attributedText = attributeSubtitle
//        }
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
