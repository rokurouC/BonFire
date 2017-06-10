//
//  Constants.swift
//  BonFire
//
//  Created by 建達 陳 on 2017/4/28.
//  Copyright © 2017年 ChienTa Chen. All rights reserved.
//

import Foundation

struct Constants {
    static let isUserFirstUseAppKey = "isUserFirstUseAppKey"
    struct FIRDatabaseConstants {
        static let users = "users"
        static let campsites = "campsites"
        struct Campsite {
            static let id = "id"
            static let latitude = "latitude"
            static let longitude = "longitude"
            static let name = "name"
            static let owner = "owner"
            static let lastmessage = "lastMessage"
            static let createtime = "createTime"
            static let jointime = "joinTime"
            static let hasjoined = "hasJoined"
            static let isowner = "isOwner"
            static let profileUrl = "profileUrl"
            static let ownerAvatarUrl = "ownerAvatarUrl"
            static let ownerDisplayName = "ownerDisplayName"
            static let badgeNumber = "badgeNumber"
            static let lastViewedTime = "lastViewedTime"
        }
        static let campsitemembers = "campsiteMembers"
        static let messages = "messages"
        struct Message {
            static let id = "id"
            static let text = "text"
            static let userId = "userId"
            static let timestamp = "timestamp"
            static let displayUserName = "displayUserName"
            static let avatarUrl = "avatarUrl"
            static let image = "image"
            static let imageWidth = "imageWidth"
            static let imageHeight = "imageHeight"
        }
        struct User {
            static let uid = "uid"
            static let name = "name"
            static let displayName = "displayName"
            static let campsites = "campsites"
            static let avatarUrl = "avatarUrl"
            static let email = "email"
            static let about = "about"
        }
    }
    struct FIRStorageConstants {
        static let profileAvatar_image = "profileAvatar_image"
        static let campsiteProfile_image = "campsiteProfile_image"
        static let message_image = "message_image"
    }
    struct PermissionScopeConstants {
        struct LocationWhileInUsePermission {
            static let header = "Need Location"
            static let body = "🏝"
            static let message = "For all features, please enable BonFire to know where you are!"
        }
        
        struct PhotosPermission {
            static let header = "Need Photos"
            static let body = "🏞"
            static let message = "For picking photos from library, please enable BonFire to use it!"
            
        }
        struct CameraPermission {
            static let header = "Need Camera"
            static let body = "📷"
            static let message = "For taking pictures by camera, please enable BonFire to use it!"
            
        }
    }
}

