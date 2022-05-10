//
//  NewConversationCell.swift
//  Chatie
//
//  Created by Rdm on 23/04/2022.
//

import Foundation
import UIKit
import SDWebImage

class NewConversationCell: UITableViewCell {

    static let cellIdentifier = "chatCell"
    
    private let userImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .yellow
        imageView.layer.cornerRadius = 25
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .white
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(userImageView)
        contentView.addSubview(userNameLabel)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        userImageView.frame = CGRect(x: 5, y: 5, width: 50, height: 50)
        userNameLabel.frame = CGRect(x: 60, y: 15, width: 300, height: 30)
        
    }
    
    
    public func configure(with model: SearchUserResult) {
      
        let path = "images/\(model.email)_profile_picture.png"
        print(path)
        
        userNameLabel.text = model.name
        
        StorageManager.shared.downloadUrl(for: path, completion: { [weak self] result in
            switch result {
            case .success(let url):
                DispatchQueue.main.async {
                    self?.userImageView.sd_setImage(with: url, completed: nil)
                }
            case .failure(let error):
                print("failed to get user image: \(error)")
            }
        })
    }
    
    func setupView() {
        backgroundColor = UIColor.init(r: 50, g: 180, b: 80)
    }

}
