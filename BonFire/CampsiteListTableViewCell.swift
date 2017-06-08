//
//  CampsiteListTableViewCell.swift
//  BonFire
//
//  Created by 建達 陳 on 2017/5/2.
//  Copyright © 2017年 ChienTa Chen. All rights reserved.
//

import UIKit

class CampsiteListTableViewCell: UITableViewCell {

    @IBOutlet weak var badgeLabel: UILabel!
    @IBOutlet weak var campsiteImage: UIImageView!
    @IBOutlet weak var campsiteNameLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var timeStringLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        campsiteImage.layer.cornerRadius = campsiteImage.frame.width/2
        badgeLabel.layer.cornerRadius = 12
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setup(campsite:Campsite) {
        self.campsiteImage.loadImageUsingCacheWithUrlString(urlString: campsite.profileUrl, placeholdSize: nil)
        self.campsiteNameLabel.text = campsite.name
        if let lastMessage = campsite.lastMessage, let _ = lastMessage.messageImageUrl {
            self.lastMessageLabel.text = "\(lastMessage.displayUserName): Sent a picture."
            self.timeStringLabel.text = lastMessage.timeString
        }else if let lastMessage = campsite.lastMessage, let text = lastMessage.messageText {
            self.lastMessageLabel.text = "\(lastMessage.displayUserName): \(text)"
            self.timeStringLabel.text = lastMessage.timeString
        }else {
            self.lastMessageLabel.text = ""
            self.timeStringLabel.text = ""
        }
        self.badgeLabel.text = String(campsite.badgeNumber)
        self.badgeLabel.isHidden = campsite.badgeNumber == 0
    }

}
