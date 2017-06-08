//
//  User.swift
//  BonFire
//
//  Created by 建達 陳 on 2017/5/1.
//  Copyright © 2017年 ChienTa Chen. All rights reserved.
//

import Foundation

struct BonFireUser {
    let uId:String
    let appDisplayName:String
    let email:String
    let avatarUrl:String
    let about:String
    
    init(userDic:[String:Any]) {
        let id = userDic[Constants.FIRDatabaseConstants.User.uid] as! String
        let appDisplayName = userDic[Constants.FIRDatabaseConstants.User.displayName] as! String
        let email = userDic[Constants.FIRDatabaseConstants.User.email] as! String
        let avatarUrl = userDic[Constants.FIRDatabaseConstants.User.avatarUrl] as! String
        let about = userDic[Constants.FIRDatabaseConstants.User.about] as! String
        self.uId = id
        self.appDisplayName = appDisplayName
        self.email = email
        self.about = about
        self.avatarUrl = avatarUrl
    }
}
