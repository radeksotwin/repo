//
//  ColorCell.swift
//  TaskerCoreData
//
//  Created by Rdm on 29/11/2020.
//


import UIKit

class ColorCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "colorCell"
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupView()
    }
    
    func setupView() {
        imageView.image = #imageLiteral(resourceName: "check-mark")
    }
    
    
    
}
