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
    
    func uploadAndDownloadImageMessageUsingCacheWithUrlString(image:UIImage, placeholdSize:CGSize) {
        //upload image
        self.image = nil
        progressView = UIProgressView(progressViewStyle: .default)
        progressView?.center = CGPoint(x: placeholdSize.width/2, y: placeholdSize.height/2)
        progressView?.frame.size.width = placeholdSize.width - 20
        self.addSubview(progressView!)
        FirebaseClient.sharedInstance.testUploadMessageImage(image: image, quality: 0.8) { (isUploadFailed, messageImageDownUrl, progress) in
            if isUploadFailed {
                DispatchQueue.main.async {
                    self.progressView?.removeFromSuperview()
                    self.progressView = nil
                }
                UtilityFunction.shared.alert(.uploadImageFailed)
                
            }else if let progress = progress {
                self.progressView?.progress = progress / 2
            }else if let messageImageDownUrl = messageImageDownUrl {
                self.downloadImageMessageUsingCacheWithUrlString(urlString: messageImageDownUrl, isdownloadRightAfterUpolad: true, placeholdSize: placeholdSize)
            }
        }
    }
    
    func downloadImageMessageUsingCacheWithUrlString(urlString:String, isdownloadRightAfterUpolad:Bool, placeholdSize:CGSize) {
        cacheUrlString = urlString
        if !isdownloadRightAfterUpolad {
            if let cacheImage = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
                self.image = cacheImage
            }else if let url = URL(string: urlString) {
                progressView = UIProgressView(progressViewStyle: .default)
                progressView?.center = CGPoint(x: placeholdSize.width/2, y: placeholdSize.height/2)
                progressView?.frame.size.width = placeholdSize.width - 20
                self.addSubview(progressView!)
                let configuration = URLSessionConfiguration.default
                let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
                session.downloadTask(with: url)
            }
        }else {
            self.isdownloadRightAfterUpolad = true
            if let url = URL(string: urlString) {
                let configuration = URLSessionConfiguration.default
                let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
                session.downloadTask(with: url)
            }
        }
    }
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let initialValue = self.isdownloadRightAfterUpolad == true ? Float(0.5) : Float(0)
        progressView?.progress = initialValue + ((Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)) / 2)
    }
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        if let progressView = progressView {
            DispatchQueue.main.async {
                progressView.removeFromSuperview()
                self.progressView = nil
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
