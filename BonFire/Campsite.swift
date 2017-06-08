//
//  Campsite.swift
//  BonFire
//
//  Created by 建達 陳 on 2017/5/1.
//  Copyright © 2017年 ChienTa Chen. All rights reserved.
//

import Foundation

struct Campsite {
    let id:String
    var lastMessage:Message?
    let latitude:Double
    let longitude:Double
    let name:String
    let owner:String //uid
    let ownerAvatarUrl:String
    let ownerDisplayName:String
    let profileUrl:String
    let createTime:Double
    var joinedTime:Double?
    var badgeNumber:Int
    var lastViewedTime:Double?
    
    init(dataDic:[String:Any]) {
        let id = dataDic[Constants.FIRDatabaseConstants.Campsite.id] as! String
        var message:Message?
        if let dic = dataDic[Constants.FIRDatabaseConstants.Campsite.lastmessage] as? [String:Any] {
            message = Message(dic)
        }
        let latitude = dataDic[Constants.FIRDatabaseConstants.Campsite.latitude] as! Double
        let longitude = dataDic[Constants.FIRDatabaseConstants.Campsite.longitude] as! Double
        let name = dataDic[Constants.FIRDatabaseConstants.Campsite.name] as! String
        let owner = dataDic[Constants.FIRDatabaseConstants.Campsite.owner] as! String
        let profileUrl = dataDic[Constants.FIRDatabaseConstants.Campsite.profileUrl] as! String
        let ownerAvatarUrl = dataDic[Constants.FIRDatabaseConstants.Campsite.ownerAvatarUrl] as! String
        let ownerDisplayName = dataDic[Constants.FIRDatabaseConstants.Campsite.ownerDisplayName] as! String
        let joinedTime = dataDic[Constants.FIRDatabaseConstants.Campsite.jointime] as? Double
        let createTime = dataDic[Constants.FIRDatabaseConstants.Campsite.createtime] as! Double
        let badgeNumber = dataDic[Constants.FIRDatabaseConstants.Campsite.badgeNumber] as? Int
        let lastViewedTime = dataDic[Constants.FIRDatabaseConstants.Campsite.lastViewedTime] as? Double
        self.id = id
        self.lastMessage = message ?? nil
        self.latitude = latitude
        self.longitude = longitude
        self.name = name
        self.owner = owner
        self.profileUrl = profileUrl
        self.ownerAvatarUrl = ownerAvatarUrl
        self.ownerDisplayName = ownerDisplayName
        self.joinedTime = joinedTime
        self.createTime = createTime
        self.badgeNumber = badgeNumber ?? 0
        self.lastViewedTime = lastViewedTime ?? joinedTime
    }
}
