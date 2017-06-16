//
//  UIImageView.swift
//  BonFire
//
//  Created by 建達 陳 on 2017/5/8.
//  Copyright © 2017年 ChienTa Chen. All rights reserved.
//

import UIKit

let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {
    func loadImageUsingCacheWithUrlString(urlString:String, placeholdSize:CGSize?) {
        self.image = nil
        if let cacheImage = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
            self.image = cacheImage
        }else if let url = URL(string: urlString) {
            let active = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            if let size = placeholdSize {
                active.center = CGPoint(x: size.width/2, y: size.height/2)
            }else {
                active.center = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
            }
            
            self.addSubview(active)
            active.startAnimating()
            
            
            URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                DispatchQueue.main.async {
                    active.stopAnimating()
                    active.removeFromSuperview()
                }
                guard error == nil else {
                    if let error = error as NSError?{
                        if error.code == -1009 {
                            UtilityFunction.shared.alert(.imageLoadFailed)
                        }
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    if let downloadImage = UIImage(data: data!) {
                        imageCache.setObject(downloadImage, forKey: urlString as AnyObject)
                        self.image = downloadImage
                    }
                    
                }
            }).resume()
        }
    }
}
