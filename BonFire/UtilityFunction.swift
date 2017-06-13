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
    private var getUserLocationFailedAlert:UIAlertController?
    private var unableSendImageMessageWithoutConnectionAlert:UIAlertController?

    func activityIndicatorViewWithCnterFrame(style:UIActivityIndicatorViewStyle, targetView:UIView) -> UIActivityIndicatorView {
        let activity = UIActivityIndicatorView(activityIndicatorStyle: style)
        activity.center = targetView.center
        targetView.addSubview(activity)
        return activity
    }
    
    func alertUnreachable() {
        let alert = UIAlertController(title: Constants.AlertConstants.UnreachableAlert.title, message: Constants.AlertConstants.UnreachableAlert.message, preferredStyle: .alert)
        let ok = UIAlertAction(title: Constants.confirm, style: .default) { [unowned self](_) in
            self.internetUnreachableAlert = nil
        }
        alert.addAction(ok)
        if let visibleVC = UIApplication.shared.keyWindow?.visibleViewController, internetUnreachableAlert == nil {
            internetUnreachableAlert = alert
            DispatchQueue.main.async {
                visibleVC.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func alertImageLoadFailed() {
        let alert = UIAlertController(title: Constants.AlertConstants.LoadFailedAlert.title, message: Constants.AlertConstants.LoadFailedAlert.message, preferredStyle: .alert)
        let ok = UIAlertAction(title: Constants.confirm, style: .default){ [unowned self](_) in
            self.imageLoadFailedAlert = nil
        }

        alert.addAction(ok)
        if let visibleVC = UIApplication.shared.keyWindow?.visibleViewController, imageLoadFailedAlert == nil {
            imageLoadFailedAlert = alert
            DispatchQueue.main.async {
                visibleVC.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func alertGetUserLocationFailed() {
        let alert = UIAlertController(title: Constants.AlertConstants.GetUserLocationFailedAlert.title, message: Constants.AlertConstants.GetUserLocationFailedAlert.message, preferredStyle: .alert)
        let ok = UIAlertAction(title: Constants.confirm, style: .default){ [unowned self](_) in
            self.getUserLocationFailedAlert = nil
        }
        alert.addAction(ok)
        if let visibleVC = UIApplication.shared.keyWindow?.visibleViewController, getUserLocationFailedAlert == nil {
            getUserLocationFailedAlert = alert
            DispatchQueue.main.async {
                visibleVC.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func alertUnableSendImageMessageWithoutConnection() {
        let alert = UIAlertController(title: Constants.AlertConstants.UnableSendImageMessageWithoutConnectionAlert.title, message: Constants.AlertConstants.UnableSendImageMessageWithoutConnectionAlert.message, preferredStyle: .alert)
        let ok = UIAlertAction(title: Constants.confirm, style: .default){ [unowned self](_) in
            self.unableSendImageMessageWithoutConnectionAlert = nil
        }
        alert.addAction(ok)
        if let visibleVC = UIApplication.shared.keyWindow?.visibleViewController, unableSendImageMessageWithoutConnectionAlert == nil {
            unableSendImageMessageWithoutConnectionAlert = alert
            DispatchQueue.main.async {
                visibleVC.present(alert, animated: true, completion: nil)
            }
        }
    }
}
