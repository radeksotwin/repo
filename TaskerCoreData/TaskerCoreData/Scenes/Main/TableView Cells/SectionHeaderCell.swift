//
//  SectionHeaderCell.swift
//  TaskerCoreData
//
//  Created by Rdm on 20/11/2020.
//

import Foundation
import UIKit


class SectionHeaderCell: UITableViewCell {
    
    
    static let identifier = "headerCell"
    
    @IBOutlet weak var sectionTitle: UILabel!
    
    var title: String?
    
    override class func awakeFromNib() {
        super.awakeFromNib()
   
    }
    
}
