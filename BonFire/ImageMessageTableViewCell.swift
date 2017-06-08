//
//  ImageMessageTableViewCell.swift
//  BonFire
//
//  Created by 建達 陳 on 2017/5/11.
//  Copyright © 2017年 ChienTa Chen. All rights reserved.
//

import UIKit
enum MessageSender {
    case user
    case others
}
class ImageMessageTableViewCell: UITableViewCell {
    var messageImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    var avatarImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    var nameLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var timeLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    convenience init(style: UITableViewCellStyle, reuseIdentifier: String?, placeholderSize:CGSize, sender:MessageSender, message:Message) {
        self.init(style: style, reuseIdentifier: reuseIdentifier)
        let fixSize = calFixedSize(placeholderSize: placeholderSize)
        self.contentView.addSubview(avatarImageView)
        self.contentView.addSubview(messageImageView)
        self.contentView.addSubview(nameLabel)
        self.contentView.addSubview(timeLabel)
        switch sender {
        case .user:
            //avatarImageView Layout
            avatarImageView.loadImageUsingCacheWithUrlString(urlString: message.avatarUrl, placeholdSize: nil)
            avatarImageView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 8).isActive = true
            avatarImageView.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -8).isActive = true
            avatarImageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
            avatarImageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
            avatarImageView.layer.cornerRadius = 15
            //nameLabel Layout
            nameLabel.text = message.displayUserName
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.topAnchor).isActive = true
            nameLabel.rightAnchor.constraint(equalTo: avatarImageView.leftAnchor, constant: -8).isActive = true
            //imageView Layout
            messageImageView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4).isActive = true
            messageImageView.rightAnchor.constraint(equalTo: nameLabel.rightAnchor).isActive = true
            messageImageView.widthAnchor.constraint(equalToConstant: fixSize.width).isActive = true
            messageImageView.heightAnchor.constraint(equalToConstant: fixSize.height).isActive = true
            messageImageView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -4).isActive = true
            messageImageView.layer.cornerRadius = 5
            messageImageView.loadImageUsingCacheWithUrlString(urlString: message.messageImageUrl!, placeholdSize: message.messageImageSize)
            //timeLabel Layout
            timeLabel.text = message.timeString
            timeLabel.bottomAnchor.constraint(equalTo: messageImageView.bottomAnchor, constant: -5).isActive = true
            timeLabel.rightAnchor.constraint(equalTo: messageImageView.leftAnchor, constant: -8).isActive = true
        case .others:
            //avatarImageView Layout
            avatarImageView.loadImageUsingCacheWithUrlString(urlString: message.avatarUrl, placeholdSize: nil)
            avatarImageView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 8).isActive = true
            avatarImageView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 8).isActive = true
            avatarImageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
            avatarImageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
            avatarImageView.layer.cornerRadius = 15
            //nameLabel Layout
            nameLabel.text = message.displayUserName
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.topAnchor).isActive = true
            nameLabel.leftAnchor.constraint(equalTo: avatarImageView.rightAnchor, constant: 8).isActive = true
            //imageView Layout
            messageImageView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4).isActive = true
            messageImageView.leftAnchor.constraint(equalTo: nameLabel.leftAnchor).isActive = true
            messageImageView.widthAnchor.constraint(equalToConstant: fixSize.width).isActive = true
            messageImageView.heightAnchor.constraint(equalToConstant: fixSize.height).isActive = true
            messageImageView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -4).isActive = true
            messageImageView.layer.cornerRadius = 5
            messageImageView.loadImageUsingCacheWithUrlString(urlString: message.messageImageUrl!, placeholdSize: message.messageImageSize)
            //timeLabel Layout
            timeLabel.text = message.timeString
            timeLabel.bottomAnchor.constraint(equalTo: messageImageView.bottomAnchor, constant: -5).isActive = true
            timeLabel.leftAnchor.constraint(equalTo: messageImageView.rightAnchor, constant: 8).isActive = true
        }
        
        
    }
    
    func calFixedSize(placeholderSize:CGSize) -> CGSize {
        
        let newSize:CGSize!
        let fitSizeWidth = UIScreen.main.bounds.width * 0.6
        if placeholderSize.width > fitSizeWidth {
            newSize = CGSize(width: fitSizeWidth, height: placeholderSize.height * (fitSizeWidth/placeholderSize.width))
        }else {
            newSize = placeholderSize
        }
        messageImageView.translatesAutoresizingMaskIntoConstraints = false
        messageImageView.widthAnchor.constraint(equalToConstant: newSize.width).isActive = true
        messageImageView.heightAnchor.constraint(equalToConstant: newSize.height).isActive = true
        setNeedsDisplay()
        return newSize
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
