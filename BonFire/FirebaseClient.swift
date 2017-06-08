//
//  FirebaseClient.swift
//  BonFire
//
//  Created by 建達 陳 on 2017/5/2.
//  Copyright © 2017年 ChienTa Chen. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuthUI
import FirebaseGoogleAuthUI
import FirebaseFacebookAuthUI

class FirebaseClient:NSObject {
    static let sharedInstance = FirebaseClient()
    var firDatabaseRef:DatabaseReference = Database.database().reference()
    
    //MARK: - Database Reference
    private let rootRef = FirebaseClient.sharedInstance.firDatabaseRef
    private let campsitesRef = FirebaseClient.sharedInstance.firDatabaseRef.child(Constants.FIRDatabaseConstants.campsites)
    private let messagesRef = FirebaseClient.sharedInstance.firDatabaseRef.child(Constants.FIRDatabaseConstants.messages)
    private let usersRef = FirebaseClient.sharedInstance.firDatabaseRef.child(Constants.FIRDatabaseConstants.users)
    
    ///User who login and using App
    var currentUser:User?
    
    ///if signed in return an User ; if signed out user be nil, and controller has to present authViewController
    func addAuthStatusDidChangeListener(completion:@escaping (_ user:BonFireUser?, _ isJustCreate:Bool, _ isSignedIn:Bool, _ authViewController:UINavigationController?) -> Void) -> AuthStateDidChangeListenerHandle {
        let authHandle:AuthStateDidChangeListenerHandle!
        let provider:[FUIAuthProvider] = [FUIGoogleAuth(), FUIFacebookAuth()]
        FUIAuth.defaultAuthUI()?.providers = provider
        FUIAuth.defaultAuthUI()?.delegate = self
        authHandle = Auth.auth().addStateDidChangeListener(){ (auth, user) in
            
            if let activeUser = user {
                if self.currentUser != activeUser {
                    self.currentUser = activeUser
                }
                self.getUserInfoWithId(userId: self.currentUser!.uid, completion: { (user) in
                    guard user != nil else {
                        completion(nil, true, true, nil)
                        
                        return
                    }
                    completion(user!, false, true, nil)
                })
            }else {
                let authViewController = FUIAuth.defaultAuthUI()?.authViewController()
                completion(nil, false, false, authViewController)
            }
        }
        return authHandle
    }
    
    func observeAllCampsitesAdd(completion:@escaping (_ campsite:Campsite?) ->Void) -> DatabaseHandle {
        let _campsitesHandle:DatabaseHandle!
        _campsitesHandle = campsitesRef.observe(.childAdded, with: { (campsiteSnapShot) in
            guard campsiteSnapShot.exists() else {
                completion(nil)
                return
            }
            let campsiteDic = campsiteSnapShot.value as! [String:Any]
            let campsite = Campsite(dataDic: campsiteDic)
            completion(campsite)
        })
        return _campsitesHandle
    }
    
    func getAllCampsitesOfUser(user:BonFireUser, completion:@escaping (_ campsites:[Campsite]?) ->Void) {
        var campsites:[Campsite]?
        //test
        usersRef.child(user.uId).child(Constants.FIRDatabaseConstants.User.campsites).keepSynced(true)
        usersRef.child(user.uId).child(Constants.FIRDatabaseConstants.User.campsites).observeSingleEvent(of: .value, with: { (campsitesSnapShots) in
            guard campsitesSnapShots.exists() else {
                completion(nil)
                return
            }
            campsites = [Campsite]()
            let campsitesDic = campsitesSnapShots.value as! [String:[String:Any]]
            let hasJoinedCount = campsitesDic.filter({ (_, value) -> Bool in
                value[Constants.FIRDatabaseConstants.Campsite.hasjoined] as! Bool == true
            }).count
            for (_, campsiteDic) in campsitesDic {
                let hasJoined = campsiteDic[Constants.FIRDatabaseConstants.Campsite.hasjoined] as! Bool
                if hasJoined {
                    var campsite = Campsite(dataDic: campsiteDic)
                    self.getLastMessageAndBadgesOfCampsiteAfterLastViewed(user: user, campsite: campsite, completion: { (badge, lastMessage) in
                        if let message = lastMessage {
                            campsite.lastMessage = message
                        }
                        campsite.badgeNumber = badge
                        campsites?.append(campsite)
                        if campsites?.count == hasJoinedCount {
                            let sortedCampsites = campsites?.sorted {
                                let compa0 = $0.lastMessage?.timestamp ?? $0.joinedTime!
                                let compa1 = $1.lastMessage?.timestamp ?? $0.joinedTime!
                                return compa0 > compa1
                            }
                            completion(sortedCampsites!)
                        }
                    })
                }
            }
        })
    }
    
    func updateUserCampsiteLastMessageAndBadge(user:BonFireUser, campsite:Campsite, isViewed:Bool, completion:@escaping (_ isUpdateSuccess:Bool)->Void) {
        var messageValues:[String:Any]? = nil
        
        if let message = campsite.lastMessage {
            if let imageUrl = message.messageImageUrl {
                //update image message
                messageValues = [Constants.FIRDatabaseConstants.Message.id:message.messageId,
                                 Constants.FIRDatabaseConstants.Message.userId:message.userId,
                                 Constants.FIRDatabaseConstants.Message.image:imageUrl as Any,Constants.FIRDatabaseConstants.Message.imageWidth:Double(message.messageImageSize!.width),
                                 Constants.FIRDatabaseConstants.Message.imageHeight:Double(message.messageImageSize!.height),
                                 Constants.FIRDatabaseConstants.Message.timestamp:message.timestamp,
                                 Constants.FIRDatabaseConstants.Message.displayUserName:message.displayUserName,
                                 Constants.FIRDatabaseConstants.Message.avatarUrl:message.avatarUrl] as [String : Any]
            }else {
                //update text message
                messageValues = [Constants.FIRDatabaseConstants.Message.id:message.messageId,
                                 Constants.FIRDatabaseConstants.Message.userId:message.userId,
                                 Constants.FIRDatabaseConstants.Message.text:message.messageText!,
                                 Constants.FIRDatabaseConstants.Message.timestamp:message.timestamp,
                                 Constants.FIRDatabaseConstants.Message.displayUserName:message.displayUserName,
                                 Constants.FIRDatabaseConstants.Message.avatarUrl:message.avatarUrl] as [String : Any]
            }
        }
        var updateValue =  [String : Any]()
        updateValue = [Constants.FIRDatabaseConstants.Campsite.badgeNumber:campsite.badgeNumber,
                       Constants.FIRDatabaseConstants.Campsite.lastmessage:messageValues as Any]
        if isViewed {
            updateValue[Constants.FIRDatabaseConstants.Campsite.lastViewedTime] = Date.timeIntervalSinceReferenceDate
        }
        usersRef.child(user.uId).child(Constants.FIRDatabaseConstants.User.campsites).child(campsite.id).updateChildValues(updateValue) { (error, _) in
            guard error == nil else {
                print("Update Badge failed:\(error!.localizedDescription)")
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    func checkIsUserMemberOfCampsiteWithUser(user:BonFireUser, campsiteId:String, completion:@escaping (_ isMember:Bool) -> Void) {
        usersRef.child(user.uId).child(Constants.FIRDatabaseConstants.User.campsites).child(campsiteId).keepSynced(true) //test
        usersRef.child(user.uId).child(Constants.FIRDatabaseConstants.User.campsites).child(campsiteId).observeSingleEvent(of: .value, with: { (campsiteSnapShot) in
            guard campsiteSnapShot.exists() else {
                completion(false)
                return
            }
            completion(true)
        })
    }
    
    func getCampsiteInfoWithCampsiteId(campsiteId:String, completion:@escaping (_ campsite:Campsite?) -> Void) {
        campsitesRef.child(campsiteId).keepSynced(true) //test
        campsitesRef.child(campsiteId).observeSingleEvent(of: .value, with: { (campsiteSanpShot) in
            guard campsiteSanpShot.exists() else {
                completion(nil)
                return
            }
            let campsiteDic = campsiteSanpShot.value as! [String:Any]
            let campsite = Campsite(dataDic: campsiteDic)
            completion(campsite)
        })
    }
    
    func observeAllCampsitesOfUserAdd(user:BonFireUser, completion:@escaping (_ campsites:Campsite?) ->Void) -> DatabaseHandle{
        let _usercampsitesRefHandle:DatabaseHandle!
        _usercampsitesRefHandle = usersRef.child(user.uId).child(Constants.FIRDatabaseConstants.User.campsites).queryOrderedByValue().queryStarting(atValue: Date.timeIntervalSinceReferenceDate, childKey: Constants.FIRDatabaseConstants.Campsite.jointime).observe(.childAdded, with: { (campsiteSnapShot) in
            guard campsiteSnapShot.exists() else {
                completion(nil)
                return
            }
            let campsiteDic = campsiteSnapShot.value as! [String:Any]
            let campsite = Campsite(dataDic: campsiteDic)
            completion(campsite)
            
        })
        return _usercampsitesRefHandle
    }
    
    func getUserInfoWithId(userId:String, completion:@escaping (_ user:BonFireUser?) -> Void) {
        usersRef.child(userId).keepSynced(true) //test
        usersRef.child(userId).observeSingleEvent(of: .value, with: { (userInfoSnapshot) in
            guard userInfoSnapshot.exists() else {
                completion(nil)
                return
            }
            let userDic = userInfoSnapshot.value as! [String:Any]
            let user = BonFireUser(userDic: userDic)
            completion(user)
        })
    }
    
    ///call when user use App first time
    func creatUserOnDatabaseWithUserId(userId:String, email:String, displayName:String, about:String, avatarUrl:String, completion:@escaping (_ user:BonFireUser?) -> Void) {
        let userData = [Constants.FIRDatabaseConstants.User.uid:userId,
                        Constants.FIRDatabaseConstants.User.email:email,
                        Constants.FIRDatabaseConstants.User.displayName:displayName,
                        Constants.FIRDatabaseConstants.User.avatarUrl:avatarUrl,
                        Constants.FIRDatabaseConstants.User.about:about]
        usersRef.child(userId).setValue(userData) { (error, _) in
            guard error == nil else {
                completion(nil)
                return
            }
            self.getUserInfoWithId(userId: userId, completion: { (user) in
                completion(user)
            })
        }
    }
    
    func updateUserOnDatabaseWithUserId(userId:String, email:String, displayName:String, about:String, avatarUrl:String, completion:@escaping (_ user:BonFireUser?) -> Void) {
        let userData = [Constants.FIRDatabaseConstants.User.uid:userId,
                        Constants.FIRDatabaseConstants.User.email:email,
                        Constants.FIRDatabaseConstants.User.displayName:displayName,
                        Constants.FIRDatabaseConstants.User.avatarUrl:avatarUrl,
                        Constants.FIRDatabaseConstants.User.about:about]
        usersRef.child(userId).updateChildValues(userData) { (error, _) in
            guard error == nil else {
                completion(nil)
                return
            }
            self.getUserInfoWithId(userId: userId, completion: { (user) in
                completion(user)
            })
        }
    }
    
    func createCampsiteWithUser(user:BonFireUser, campsiteName:String, userLocation:CLLocation, profileImage:UIImage, completion:@escaping (_ campsite:Campsite?)-> Void) {
        FirebaseClient.sharedInstance.uploadCampsiteProfileImage(image: profileImage, quality: 0.3) { (downloadUrl) in
            let campsiteAutoId = self.campsitesRef.childByAutoId().key
            let createTime = Date.timeIntervalSinceReferenceDate
            let campsiteData = [Constants.FIRDatabaseConstants.Campsite.id:campsiteAutoId,
                                Constants.FIRDatabaseConstants.Campsite.name:campsiteName,
                                Constants.FIRDatabaseConstants.Campsite.owner:user.uId,
                                Constants.FIRDatabaseConstants.Campsite.ownerDisplayName:user.appDisplayName,
                                Constants.FIRDatabaseConstants.Campsite.createtime:createTime,
                                Constants.FIRDatabaseConstants.Campsite.profileUrl:downloadUrl,
                                Constants.FIRDatabaseConstants.Campsite.ownerAvatarUrl:user.avatarUrl,
                                Constants.FIRDatabaseConstants.Campsite.latitude:userLocation.coordinate.latitude,
                                Constants.FIRDatabaseConstants.Campsite.longitude:userLocation.coordinate.longitude] as [String : Any]
            let campsitemembersData = [Constants.FIRDatabaseConstants.User.uid:user.uId,
                                       Constants.FIRDatabaseConstants.User.avatarUrl:user.avatarUrl,
                                       Constants.FIRDatabaseConstants.User.displayName:user.appDisplayName,
                                       Constants.FIRDatabaseConstants.User.email:user.email,
                                       Constants.FIRDatabaseConstants.Campsite.isowner:true,
                                       Constants.FIRDatabaseConstants.Campsite.hasjoined:true,
                                       Constants.FIRDatabaseConstants.Campsite.jointime:createTime] as [String : Any]
            let userCampsiteData = [Constants.FIRDatabaseConstants.Campsite.id:campsiteAutoId,
                                    Constants.FIRDatabaseConstants.Campsite.name:campsiteName,
                                    Constants.FIRDatabaseConstants.Campsite.owner:user.uId,
                                    Constants.FIRDatabaseConstants.Campsite.ownerDisplayName:user.appDisplayName,
                                    Constants.FIRDatabaseConstants.Campsite.createtime:createTime,
                                    Constants.FIRDatabaseConstants.Campsite.profileUrl:downloadUrl,
                                    Constants.FIRDatabaseConstants.Campsite.ownerAvatarUrl:user.avatarUrl,
                                    Constants.FIRDatabaseConstants.Campsite.latitude:userLocation.coordinate.latitude,
                                    Constants.FIRDatabaseConstants.Campsite.longitude:userLocation.coordinate.longitude,
                                    Constants.FIRDatabaseConstants.Campsite.hasjoined:true,
                                    Constants.FIRDatabaseConstants.Campsite.jointime:Date.timeIntervalSinceReferenceDate] as [String : Any]
            let childUpdates = ["/\(Constants.FIRDatabaseConstants.campsites)/\(campsiteAutoId)":campsiteData,
                                "/\(Constants.FIRDatabaseConstants.campsitemembers)/\(campsiteAutoId)/\(user.uId)":campsitemembersData,
                                "/\(Constants.FIRDatabaseConstants.users)/\(user.uId)/\(Constants.FIRDatabaseConstants.User.campsites)/\(campsiteAutoId)":userCampsiteData] as [String : Any]
            self.rootRef.updateChildValues(childUpdates) { (error, _) in
                guard error == nil else { return }
                self.getCampsiteInfoWithCampsiteId(campsiteId: campsiteAutoId, completion: { (campsite) in
                    guard campsite != nil else {
                        completion(nil)
                        return
                    }
                    completion(campsite)
                })
                
            }
        }
    }
    
    func setUserForMemberOfCampsiteWithId(user:BonFireUser, campsite:Campsite, completion:@escaping () -> Void) {
        let joinTime = Date.timeIntervalSinceReferenceDate
        let userCampsiteData = [Constants.FIRDatabaseConstants.Campsite.id:campsite.id,
                                Constants.FIRDatabaseConstants.Campsite.name:campsite.name,
                                Constants.FIRDatabaseConstants.Campsite.owner:campsite.owner,
                                Constants.FIRDatabaseConstants.Campsite.ownerDisplayName:campsite.ownerDisplayName,
                                Constants.FIRDatabaseConstants.Campsite.createtime:campsite.createTime,
                                Constants.FIRDatabaseConstants.Campsite.profileUrl:campsite.profileUrl,
                                Constants.FIRDatabaseConstants.Campsite.ownerAvatarUrl:campsite.ownerAvatarUrl,
                                Constants.FIRDatabaseConstants.Campsite.latitude:campsite.latitude,
                                Constants.FIRDatabaseConstants.Campsite.longitude:campsite.longitude,
                                Constants.FIRDatabaseConstants.Campsite.hasjoined:true,
                                Constants.FIRDatabaseConstants.Campsite.jointime:joinTime] as [String : Any]
        let campsitemembersData = [Constants.FIRDatabaseConstants.User.uid:user.uId,
                                   Constants.FIRDatabaseConstants.User.avatarUrl:user.avatarUrl,
                                   Constants.FIRDatabaseConstants.User.displayName:user.appDisplayName,
                                   Constants.FIRDatabaseConstants.User.email:user.email,
                                   Constants.FIRDatabaseConstants.Campsite.isowner:false,
                                   Constants.FIRDatabaseConstants.Campsite.hasjoined:true,
                                   Constants.FIRDatabaseConstants.Campsite.jointime:Date.timeIntervalSinceReferenceDate] as [String : Any]
        let childUpdates = ["/\(Constants.FIRDatabaseConstants.campsitemembers)/\(campsite.id)/\(user.uId)":campsitemembersData,
                            "/\(Constants.FIRDatabaseConstants.users)/\(user.uId)/\(Constants.FIRDatabaseConstants.User.campsites)/\(campsite.id)":userCampsiteData] as [String : Any]
        rootRef.updateChildValues(childUpdates) { (error, _) in
            guard error == nil else { return }
            completion()
        }
    }
    
    func addTextMessageToCampsite(user:BonFireUser, text:String, campsiteId:String) {
        let messageId = messagesRef.child(campsiteId).childByAutoId().key
        
        let campsitesMessageRefData = [Constants.FIRDatabaseConstants.Message.id:messageId,
                                       Constants.FIRDatabaseConstants.Message.userId:user.uId,
                                       Constants.FIRDatabaseConstants.Message.text:text,
                                       Constants.FIRDatabaseConstants.Message.timestamp:Date.timeIntervalSinceReferenceDate,
                                       Constants.FIRDatabaseConstants.Message.displayUserName:user.appDisplayName,
                                       Constants.FIRDatabaseConstants.Message.avatarUrl:user.avatarUrl] as [String : Any]
        rootRef.updateChildValues(["/\(Constants.FIRDatabaseConstants.campsites)/\(campsiteId)/\(Constants.FIRDatabaseConstants.Campsite.lastmessage)/":campsitesMessageRefData, "/\(Constants.FIRDatabaseConstants.messages)/\(campsiteId)/\(messageId)":campsitesMessageRefData])
    }
    
    func addImageMessageToCampsite(user:BonFireUser, image:UIImage, campsiteId:String, quality:CGFloat) {
        let messageId = messagesRef.child(campsiteId).childByAutoId().key
        uploadMessageImage(image: image, quality: quality) { (downloadUrl) in
            let campsitesMessageRefData = [Constants.FIRDatabaseConstants.Message.id:messageId,
                                           Constants.FIRDatabaseConstants.Message.userId:user.uId,
                                           Constants.FIRDatabaseConstants.Message.image:downloadUrl,Constants.FIRDatabaseConstants.Message.imageWidth:Double(image.size.width),
                                           Constants.FIRDatabaseConstants.Message.imageHeight:Double(image.size.height),
                                           Constants.FIRDatabaseConstants.Message.timestamp:Date.timeIntervalSinceReferenceDate,
                                           Constants.FIRDatabaseConstants.Message.displayUserName:user.appDisplayName,
                                           Constants.FIRDatabaseConstants.Message.avatarUrl:user.avatarUrl] as [String : Any]
            self.rootRef.updateChildValues(["/\(Constants.FIRDatabaseConstants.campsites)/\(campsiteId)/\(Constants.FIRDatabaseConstants.Campsite.lastmessage)/":campsitesMessageRefData, "/\(Constants.FIRDatabaseConstants.messages)/\(campsiteId)/\(messageId)":campsitesMessageRefData])
        }
    }
    
    func getMessagesOfCampsiteWithId(user:BonFireUser, campsiteId:String, completion:@escaping (_ messages:[Message]?) -> Void) {
        var messages:[Message]? = [Message]()
        let userCampsiteRef = usersRef.child(user.uId).child(Constants.FIRDatabaseConstants.User.campsites).child(campsiteId)
        let campsiteMessagesRef = messagesRef.child(campsiteId)
        userCampsiteRef.keepSynced(true) //test
        userCampsiteRef.observeSingleEvent(of: .value, with: { (userCampsiteSnapShot) in
            guard userCampsiteSnapShot.exists() else { return }
            let userCampsiteDic = userCampsiteSnapShot.value as! [String:Any]
            let hasjoined = userCampsiteDic[Constants.FIRDatabaseConstants.Campsite.hasjoined] as! Bool
            let jointime = userCampsiteDic[Constants.FIRDatabaseConstants.Campsite.jointime] as! Double
            if hasjoined {
                campsiteMessagesRef.keepSynced(true) //test
                campsiteMessagesRef.queryOrdered(byChild: Constants.FIRDatabaseConstants.Message.timestamp).queryStarting(atValue: jointime).observeSingleEvent(of: .value, with: { (messagesSnapShot) in
                    guard messagesSnapShot.exists() else {
                        completion(nil)
                        return
                    }
                    let messagesDic = messagesSnapShot.value as! [String:[String:Any]]
                    for (_ , value) in messagesDic {
                        let message = Message(value)
                        messages?.append(message)
                        if messages?.count == messagesDic.count {
                            let sortedMessage = messages?.sorted{
                                $0.timestamp < $1.timestamp
                            }
                            completion(sortedMessage)
                        }
                    }
                })
            }
        })
    }
    
    func getLastMessageAndBadgesOfCampsiteAfterLastViewed(user:BonFireUser, campsite:Campsite, completion:@escaping (_ badge:Int, _ lastMessage:Message?) -> Void) {
        
        let campsiteMessagesRef = messagesRef.child(campsite.id)
        let lastViewedTime = campsite.lastViewedTime ?? campsite.joinedTime
        campsiteMessagesRef.keepSynced(true) //test
        campsiteMessagesRef.queryOrdered(byChild: Constants.FIRDatabaseConstants.Message.timestamp).queryStarting(atValue: lastViewedTime).observeSingleEvent(of: .value, with: { (messagesSnapShot) in
            guard messagesSnapShot.exists() else {
                completion(0,nil)
                return
            }
            
            let messagesDic = messagesSnapShot.value as! [String:[String:Any]]
            let badge = messagesDic.count
            self.getLastMessageWithCampsite(campsite: campsite, completion: { (lastMessage) in
                guard lastMessage != nil else {
                    completion(0, nil)
                    return
                }
                completion(badge, lastMessage)
            })
        })
        
    }
    
    private func getLastMessageWithCampsite(campsite:Campsite, completion:@escaping (_ message:Message?) -> Void) {
        let lastMessageRef = campsitesRef.child(campsite.id).child(Constants.FIRDatabaseConstants.Campsite.lastmessage)
        lastMessageRef.keepSynced(true) //test
        lastMessageRef.observeSingleEvent(of: .value, with: { (messageSnapshot) in
            guard messageSnapshot.exists() else {
                completion(nil)
                return
            }
            
            if let messageDic = messageSnapshot.value as? [String:Any] {
                let message = Message(messageDic)
                completion(message)
            }
        })
    }
    
    func listenLastMessageOfCampsiteWithId(user:BonFireUser, campsiteId:String, completion:@escaping (_ lastMessage:Message?) -> Void) -> DatabaseHandle{
        let startListenTime = Date.timeIntervalSinceReferenceDate
        let campsiteLastMessagesRef = campsitesRef.child(campsiteId).child(Constants.FIRDatabaseConstants.Campsite.lastmessage)
        var campsiteMessagesHandle:DatabaseHandle!
        campsiteMessagesHandle = campsiteLastMessagesRef.observe(.value, with: { (messageSnapShot) in
            guard messageSnapShot.exists() else {
                completion(nil)
                return
            }
            let messageDic = messageSnapShot.value as! [String:Any]
            let timestamp = messageDic[Constants.FIRDatabaseConstants.Message.timestamp] as! Double
            guard timestamp >= startListenTime else {
                completion(nil)
                return
            }
            let message = Message(messageDic)
            completion(message)
        })
        return campsiteMessagesHandle
    }
    
    func listenUserCampsitesMessageAdd(campsites:[Campsite], completion:@escaping (_ campsite:Campsite?) -> Void) -> [(DatabaseReference,DatabaseHandle)]{
        var referenceAndHandles = [(DatabaseReference,DatabaseHandle)]()
        let startListenTime = Date.timeIntervalSinceReferenceDate
        for campsite in campsites {
            var campsiteMessagesHandle:DatabaseHandle!
            let lastMessageRef = campsitesRef.child(campsite.id).child(Constants.FIRDatabaseConstants.Campsite.lastmessage)
            
            campsiteMessagesHandle = lastMessageRef.observe(.value, with: { (messageSnapShot) in
                guard messageSnapShot.exists() else {
                    completion(nil)
                    return
                }
                var campsiteReturn = campsite
                let messageDic = messageSnapShot.value as! [String:Any]
                let message = Message(messageDic)
                let timestamp = messageDic[Constants.FIRDatabaseConstants.Message.timestamp] as! Double
                guard timestamp >= startListenTime else {
                    completion(nil)
                    return
                }
                campsiteReturn.lastMessage = message
                completion(campsiteReturn)
            })
            referenceAndHandles.append((lastMessageRef, campsiteMessagesHandle))
        }
        return referenceAndHandles
    }
    
}

extension FirebaseClient:FUIAuthDelegate {
    //MARK: - FUIAuthDelegate
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        guard  error != nil else { return }
        print(error!.localizedDescription)
    }
    
    func authPickerViewController(forAuthUI authUI: FUIAuth) -> FUIAuthPickerViewController {
        return SignInViewController(authUI: authUI)
    }
}
