//
//  ChatCell.swift
//  Chatie
//
//  Created by Rdm on 23/04/2022.
//

import UIKit
import SDWebImage

class ChatCell: UITableViewCell {

    static let cellIdentifier = "chatCell"
    
    private let userImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .yellow
        imageView.layer.cornerRadius = 35
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = .white
        return label
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.textColor = .white
        return label
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(userImageView)
        contentView.addSubview(userNameLabel)
        contentView.addSubview(messageLabel)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        userImageView.frame = CGRect(x: 5, y: 5, width: 70, height: 70)
        userNameLabel.frame = CGRect(x: 80, y: 5, width: 300, height: 30)
        messageLabel.frame = CGRect(x: 80, y: 35, width: 300, height: 40)
        
    }
    
    public func configure(with model: Conversation) {
        guard let currentUserName = UserDefaults.standard.value(forKey: "name") as? String else { return }
        
        userNameLabel.text = model.name
        
        if model.latestMessage.senderName == currentUserName {
            messageLabel.text = "You: " + "\(model.latestMessage.text)"
        } else {
            messageLabel.text = model.latestMessage.text
        }
        
        let path = "images/\(model.otherUserEmail)_profile_picture.png"
        
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
