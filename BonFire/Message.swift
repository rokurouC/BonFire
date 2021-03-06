//
//  Message.swift
//  BonFire
//
//  Created by 建達 陳 on 2017/4/26.
//  Copyright © 2017年 ChienTa Chen. All rights reserved.
//

import Foundation

struct Message {
    let messageId:String
    let userId:String
    let messageText:String?
    var messageImageUrl:String?
    let messageImageSize:CGSize?
    let timestamp:Double
    let timeString:String
    let avatarUrl:String
    let displayUserName:String
    var preloadImage:UIImage?
    

    init(_ data:[String:Any]){
        let messageId = data[Constants.FIRDatabaseConstants.Message.id] as! String
        let messageUserId = data[Constants.FIRDatabaseConstants.Message.userId] as! String
        let timestamp = data[Constants.FIRDatabaseConstants.Message.timestamp] as! Double
        let messageTimeString = Message.timeString(Date(timeIntervalSinceReferenceDate: timestamp))
        let messageDisplayUserName = data[Constants.FIRDatabaseConstants.Message.displayUserName] as! String
        let messageText = data[Constants.FIRDatabaseConstants.Message.text] as? String
        let messageImageUrl = data[Constants.FIRDatabaseConstants.Message.image] as? String
        let avatarUrl = data[Constants.FIRDatabaseConstants.Message.avatarUrl] as! String
        let imageWidth = data[Constants.FIRDatabaseConstants.Message.imageWidth] as? Double
        let imageHeight = data[Constants.FIRDatabaseConstants.Message.imageHeight] as? Double

        self.messageId = messageId
        self.userId = messageUserId
        self.messageText = messageText ?? nil
        self.messageImageUrl = messageImageUrl ?? nil
        self.timestamp = timestamp
        self.timeString = messageTimeString
        self.avatarUrl = avatarUrl
        self.displayUserName = messageDisplayUserName
        self.messageImageSize = imageWidth != nil ? CGSize(width: imageWidth!, height: imageHeight!) : nil
        self.preloadImage = nil
    }
    //test
    init(id:String, userId:String, messageText:String?, messageImageUrl:String?, timeStamp:Double, imageSize:CGSize?, avatarUrl:String, displayName:String, preloadImage:UIImage) {
        self.messageId = id
        self.userId = userId
        self.messageText = messageText
        self.messageImageUrl = messageImageUrl
        self.messageImageSize = imageSize
        self.timestamp = timeStamp
        self.timeString = Message.timeString(Date(timeIntervalSinceReferenceDate: timeStamp))
        self.avatarUrl = avatarUrl
        self.displayUserName = displayName
        self.preloadImage = preloadImage
    }
    
    static func timeString(_ date:Date) -> String {
        let dateformatter = DateFormatter()
        dateformatter.dateStyle = .none
        dateformatter.timeStyle = .medium
        return dateformatter.string(from: date)
    }
}
