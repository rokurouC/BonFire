//
//  FirebaseClient+Storage.swift
//  BonFire
//
//  Created by 建達 陳 on 2017/5/8.
//  Copyright © 2017年 ChienTa Chen. All rights reserved.
//

import Foundation
import Firebase

extension FirebaseClient {
    func uploadAvatarImage(image:UIImage, quality:CGFloat, completion:@escaping (_ avatarDownloadUrl:String) -> Void) {
        if let uploadData = UIImageJPEGRepresentation(image, quality) {
            let imageName = NSUUID().uuidString
            let avatarStorageRef = Storage.storage().reference().child(Constants.FIRStorageConstants.profileAvatar_image).child(FirebaseClient.sharedInstance.currentUser!.uid).child("\(imageName).jpg")
            avatarStorageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                guard error == nil else {
                    print(error!)
                    return
                }
                
                if let downloadUrlString = metadata?.downloadURL()?.absoluteString {
                    completion(downloadUrlString)
                }
            })
        }
    }
    
    func uploadCampsiteProfileImage(image:UIImage, quality:CGFloat, completion:@escaping (_ profileImageDownUrl:String) -> Void) {
        if let uploadData = UIImageJPEGRepresentation(image, quality) {
            let imageName = NSUUID().uuidString
            let profileImageStorageRef = Storage.storage().reference().child(Constants.FIRStorageConstants.campsiteProfile_image).child("\(imageName).jpg")
            profileImageStorageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                guard error == nil else {
                    print(error!)
                    return
                }
                if let downloadUrlString = metadata?.downloadURL()?.absoluteString {
                    completion(downloadUrlString)
                }
            })
        }
    }
    
    func uploadMessageImage(image:UIImage, quality:CGFloat, completion:@escaping (_ messageImageDownUrl:String) -> Void) {
        if let uploadData = UIImageJPEGRepresentation(image, quality) {
            let imageName = NSUUID().uuidString
            let messageImageStorageRef = Storage.storage().reference().child(Constants.FIRStorageConstants.message_image).child("\(imageName)")
            messageImageStorageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                guard error == nil else {
                    print(error!)
                    return
                }
                if let downloadUrlString = metadata?.downloadURL()?.absoluteString {
                    completion(downloadUrlString)
                }
            })
            
        }
    }
    
    func testUploadMessageImage(image:UIImage, quality:CGFloat, completion:@escaping (_ isUploadFailed:Bool, _ messageImageDownUrl:String?, _ progress:Float?) -> Void) {
        if let uploadData = UIImageJPEGRepresentation(image, quality) {
            let imageName = NSUUID().uuidString
            let messageImageStorageRef = Storage.storage().reference().child(Constants.FIRStorageConstants.message_image).child("\(imageName)")
            let uploadTask = messageImageStorageRef.putData(uploadData, metadata: nil)
            uploadTask.observe(.progress, handler: { (progressSnapshot) in
                if let completedUnitCount = progressSnapshot.progress?.completedUnitCount , let totalUnitCount = progressSnapshot.progress?.totalUnitCount {
                    let percentComplete = Float(completedUnitCount) / Float(totalUnitCount)
                    completion(false, nil, percentComplete)
                }
            })
            uploadTask.observe(.success, handler: { (successSnapshot) in
                uploadTask.removeAllObservers()
                if let downloadUrlString = successSnapshot.metadata?.downloadURL()?.absoluteString {
                    completion(false, downloadUrlString, nil)
                }
            })
            uploadTask.observe(.failure, handler: { (failureSnapshot) in
                uploadTask.removeAllObservers()
                if let _ = failureSnapshot.error {
                    completion(true, nil, nil)
                }
//                if let error = failureSnapshot.error as? NSError {
//                    switch (StorageErrorCode(rawValue: error.code)!) {
//                        //StorageErrorCode case implement
//                    }
//                }
            })
            
            
        }
    }
    
    
    
}

