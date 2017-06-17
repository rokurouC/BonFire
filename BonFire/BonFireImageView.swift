//
//  BonFireImageView.swift
//  BonFire
//
//  Created by 建達 陳 on 2017/6/17.
//  Copyright © 2017年 ChienTa Chen. All rights reserved.
//

import UIKit

class BonFireImageView: UIImageView, URLSessionDelegate, URLSessionDownloadDelegate {
    
    var progressView:UIProgressView?
    var isdownloadRightAfterUpolad:Bool?
    var cacheUrlString:String?
    var handlingCoverView:UIView?
    var active:UIActivityIndicatorView?
    var hasUploadBeenSuccessful:Bool?
    
    func uploadAndDownloadImageMessageUsingCacheWithUrlString(message:Message, placeholdSize:CGSize, campsiteId:String, completion:@escaping (_ messageReturn:Message) ->Void) {
        //upload image
        self.image = message.preloadImage
        handlingCoverView = UIView(frame: CGRect(origin: CGPoint.zero , size: placeholdSize))
        handlingCoverView?.backgroundColor = UIColor.black
        handlingCoverView?.alpha = 0.5
        self.addSubview(handlingCoverView!)
        progressView = UIProgressView(progressViewStyle: .default)
        progressView?.center = CGPoint(x: placeholdSize.width/2, y: placeholdSize.height/2)
        progressView?.frame.size.width = placeholdSize.width - 20
        handlingCoverView?.addSubview(progressView!)
        
        FirebaseClient.sharedInstance.uploadMessageImage(image: message.preloadImage!, quality: 0.8) { (isUploadFailed, messageImageDownUrl, progress) in
            if isUploadFailed {
                DispatchQueue.main.async {
                    self.progressView?.removeFromSuperview()
                    self.progressView = nil
                }
                UtilityFunction.shared.alert(.uploadImageFailed)
                
            }else if let progress = progress {
                DispatchQueue.main.async {
                    self.progressView?.progress = progress / 2
                }
            }else if let messageImageDownUrl = messageImageDownUrl {
                var messageForPass = message
                messageForPass.messageImageUrl = messageImageDownUrl
                //fix bug: no idea why firebase uploadtask observe seccess twice
                if self.hasUploadBeenSuccessful == nil {
                    FirebaseClient.sharedInstance.addImageMessageToCampsite(message: messageForPass, campsiteId: campsiteId)
                    self.hasUploadBeenSuccessful = true
                }
                messageForPass.preloadImage = nil
                completion(messageForPass)
                self.downloadImageMessageUsingCacheWithUrlString(urlString: messageImageDownUrl, isdownloadRightAfterUpolad: true, placeholdSize: placeholdSize)
            }
        }
    }
    
    func downloadImageMessageUsingCacheWithUrlString(urlString:String, isdownloadRightAfterUpolad:Bool, placeholdSize:CGSize) {
        cacheUrlString = urlString
        self.isdownloadRightAfterUpolad = isdownloadRightAfterUpolad
        if !isdownloadRightAfterUpolad {
            if let cacheImage = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
                self.image = cacheImage
            }else if let url = URL(string: urlString) {
                handlingCoverView = UIView(frame: CGRect(origin: CGPoint.zero , size: placeholdSize))
                handlingCoverView?.backgroundColor = UIColor.lightGray
                handlingCoverView?.alpha = 0.3
                self.addSubview(handlingCoverView!)
                active = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
                active?.center = CGPoint(x: placeholdSize.width/2, y: placeholdSize.height/2)
                handlingCoverView?.addSubview(active!)
                active!.startAnimating()
                
                let configuration = URLSessionConfiguration.default
                let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
                session.downloadTask(with: url).resume()
            }
        }else {
            if let url = URL(string: urlString) {
                let configuration = URLSessionConfiguration.default
                let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
                session.downloadTask(with: url).resume()
            }
        }
    }
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        if self.isdownloadRightAfterUpolad! {
            DispatchQueue.main.async {
                self.progressView?.progress = 0.5 + ((Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)) / 2)
            }
        }
    }
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        //isdownloadRightAfterUpolad = false
        if let active = active, let coverView = handlingCoverView{
            DispatchQueue.main.async {
                active.stopAnimating()
                active.removeFromSuperview()
                self.active = nil
                coverView.removeFromSuperview()
                self.handlingCoverView = nil
            }
        }
        //isdownloadRightAfterUpolad = true
        if let progressView = progressView, let coverView = handlingCoverView {
            DispatchQueue.main.async {
                progressView.removeFromSuperview()
                self.progressView = nil
                coverView.removeFromSuperview()
                self.handlingCoverView = nil
            }
        }
        
        do {
            let data = try Data(contentsOf: location)
            if let image = UIImage(data: data) {
                if let urlString = cacheUrlString {
                    imageCache.setObject(image, forKey: urlString as AnyObject)
                }
                DispatchQueue.main.async {
                    self.image = image
                }
            }
        }catch {
            if let flag = self.isdownloadRightAfterUpolad, flag {
                UtilityFunction.shared.alert(.uploadImageFailed)
            }else {
                UtilityFunction.shared.alert(.imageLoadFailed)
            }
            
        }
    }
}
