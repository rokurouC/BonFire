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
    static let confirm = "OK"
    static let cancel = "CANCEL"
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
    struct AlertConstants {
        struct UnreachableAlert {
            static let title = "Disconnect!"
            static let message = "Check the internet and come back later."
        }
        struct LoadFailedAlert {
            static let title = "Loading image failed!"
            static let message = "Check the internet and come back later."
        }
        struct GetUserLocationFailedAlert {
            static let title = "Get Location failed!"
            static let message = "Check the internet and come back later."
        }
        struct NoCampsitesAlert {
            static let title = "Hey"
            static let message = "You haven't joined any campsite yet, how about going back to map and choose or create one?"
        }
        struct UnableSendImageMessageWithoutConnectionAlert {
            static let title = "Sorry"
            static let message = "You can't sent photo to others without connection, please check the internet and come back later."
        }
    }
    struct PoptipConstants {
        static let firstPoptip = "Welcome to BonFire!\nTo have fun in BonFire, please connect to internet when using App.\n< Tap me to next >"
        static let secondPoptip = "You can found campsites around the world on the map and tap to join them.\n< Tap me to next >"
        static let thirdPoptip = "Then check the campsites you've joined in here.\n< Tap me to next >"
        static let fourthPoptip = "Or you can camp your own campsite and let people join you!\n< Tap me to start! >"
    }
}

