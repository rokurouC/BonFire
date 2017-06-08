//
//  UtilityFunction.swift
//  BonFire
//
//  Created by 建達 陳 on 2017/5/15.
//  Copyright © 2017年 ChienTa Chen. All rights reserved.
//

import UIKit

class UtilityFunction {
    static let shared = UtilityFunction()
    private var internetUnreachableAlert:UIAlertController?
    private var imageLoadFailedAlert:UIAlertController?
    
    func activityIndicatorViewWithCnterFrame(style:UIActivityIndicatorViewStyle, targetView:UIView) -> UIActivityIndicatorView {
        let activity = UIActivityIndicatorView(activityIndicatorStyle: style)
        activity.center = targetView.center
        targetView.addSubview(activity)
        return activity
    }
    
    func unreachableAlert() {
        let alert = UIAlertController(title: "Disconnect!", message: "Check the network and come back later.", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default) { (_) in
            self.internetUnreachableAlert = nil
        }
        alert.addAction(ok)
        if let visibleVC = UIApplication.shared.keyWindow?.visibleViewController, internetUnreachableAlert == nil {
            internetUnreachableAlert = alert
            visibleVC.present(alert, animated: true, completion: nil)
        }
    }
    
    func loadFailedAlert() {
        let alert = UIAlertController(title: "Loading image failed", message: "Check the network and come back later.", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default){ (_) in
            self.imageLoadFailedAlert = nil
        }

        alert.addAction(ok)
        if let visibleVC = UIApplication.shared.keyWindow?.visibleViewController, imageLoadFailedAlert == nil {
            imageLoadFailedAlert = alert
            visibleVC.present(alert, animated: true, completion: nil)
        }
    }
}
