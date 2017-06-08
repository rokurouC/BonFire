//
//  UserChatTableViewCell.swift
//  BonFire
//
//  Created by 建達 陳 on 2017/4/26.
//  Copyright © 2017年 ChienTa Chen. All rights reserved.
//

import UIKit

class UserChatTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var messageTextView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        messageTextView.layer.cornerRadius = 5
        avatarImageView.layer.cornerRadius = avatarImageView.frame.width/2
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setupWithData(message:Message) {
        avatarImageView.loadImageUsingCacheWithUrlString(urlString: message.avatarUrl, placeholdSize: nil)
        
        nameLabel.text = message.displayUserName
        timeLabel.text = message.timeString
        messageTextView.text = message.messageText
    }
}
