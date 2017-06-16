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
    private var alertNowPresennt:UIAlertController?
    
    func activityIndicatorViewWithCnterFrame(style:UIActivityIndicatorViewStyle, targetView:UIView) -> UIActivityIndicatorView {
        let activity = UIActivityIndicatorView(activityIndicatorStyle: style)
        activity.center = targetView.center
        targetView.addSubview(activity)
        return activity
    }
    
    enum Alert {
        case internetUnreachable
        case imageLoadFailed
        case getUserLocationFailed
        case unableSendImageMessageWithoutConnection
        case unableCreatCampsiteWithoutConnectionAlert
        case needConnectinoToLogin
        case sendTextMessageWithoutConnection
        case uploadImageFailed
    }
    
    func alert(_ type:Alert, sender:UIViewController? = nil) {
        var title:String!
        var message:String!
        switch type {
        case .internetUnreachable:
            title = Constants.AlertConstants.UnreachableAlert.title
            message = Constants.AlertConstants.UnreachableAlert.message
        case .imageLoadFailed:
            title = Constants.AlertConstants.LoadFailedAlert.title
            message = Constants.AlertConstants.LoadFailedAlert.message
        case .getUserLocationFailed:
            title = Constants.AlertConstants.GetUserLocationFailedAlert.title
            message = Constants.AlertConstants.GetUserLocationFailedAlert.message
        case .unableSendImageMessageWithoutConnection:
            title = Constants.AlertConstants.UnableSendImageMessageWithoutConnectionAlert.title
            message = Constants.AlertConstants.UnableSendImageMessageWithoutConnectionAlert.message
        case .unableCreatCampsiteWithoutConnectionAlert:
            title = Constants.AlertConstants.UnableCreatCampsiteWithoutConnectionAlert.title
            message = Constants.AlertConstants.UnableCreatCampsiteWithoutConnectionAlert.message
        case .needConnectinoToLogin:
            title = Constants.AlertConstants.NeedConnectionToLogin.title
            message = Constants.AlertConstants.NeedConnectionToLogin.message
        case .sendTextMessageWithoutConnection:
            title = Constants.AlertConstants.SendTextMessageWithoutConnection.title
            message = Constants.AlertConstants.SendTextMessageWithoutConnection.message
        case .uploadImageFailed:
            title = Constants.AlertConstants.UploadImageFailed.title
            message = Constants.AlertConstants.UploadImageFailed.message
        }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: Constants.confirm, style: .default){ [unowned self](_) in
            self.alertNowPresennt = nil
        }
        alert.addAction(ok)
        if let vc = sender, alertNowPresennt == nil {
            alertNowPresennt = alert
            DispatchQueue.main.async {
                vc.present(alert, animated: true, completion: nil)
            }
        }else if let visibleVC = UIApplication.shared.keyWindow?.visibleViewController, alertNowPresennt == nil {
            alertNowPresennt = alert
            DispatchQueue.main.async {
                visibleVC.present(alert, animated: true, completion: nil)
            }
        }
    }
}
