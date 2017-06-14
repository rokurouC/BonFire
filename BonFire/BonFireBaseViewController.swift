//
//  BonFireBaseViewController.swift
//  BonFire
//
//  Created by 建達 陳 on 2017/5/8.
//  Copyright © 2017年 ChienTa Chen. All rights reserved.
//

import UIKit
import PermissionScope
import ReachabilitySwift

class BonFireBaseViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let pscopeCamera:PermissionScope = {
        let pscope = PermissionScope()
        pscope.headerLabel.text = Constants.PermissionScopeConstants.CameraPermission.header
        pscope.bodyLabel.text = Constants.PermissionScopeConstants.CameraPermission.body
        pscope.addPermission(CameraPermission(), message: Constants.PermissionScopeConstants.CameraPermission.message)
        return pscope
    }()
    let pscopePhoto:PermissionScope = {
        let pscope = PermissionScope()
        pscope.headerLabel.text = Constants.PermissionScopeConstants.PhotosPermission.header
        pscope.bodyLabel.text = Constants.PermissionScopeConstants.PhotosPermission.body
        pscope.addPermission(PhotosPermission(), message: Constants.PermissionScopeConstants.PhotosPermission.message)
        return pscope
    }()
    var reachability: Reachability?
    var currentUser:BonFireUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reachability = Reachability()
        startReachabilityNotifier()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startReachabilityNotifier()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopReachabilityNotifier()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let isReachable = reachability?.isReachable, !isReachable {
            UtilityFunction.shared.alert(.internetUnreachable)
        }
    }
    
    func startReachabilityNotifier() {
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(_:)), name: ReachabilityChangedNotification, object: reachability)
        do {
            try reachability?.startNotifier()
        }catch {
            print("Unable to start\nnotifier network.")
        }
    }
    
    func stopReachabilityNotifier() {
        reachability?.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: ReachabilityChangedNotification, object: nil)
    }
    
    @objc private func reachabilityChanged(_ note: Notification) {
        if let reachability = note.object as? Reachability {
            if !reachability.isReachable {
                reachabilityUnreachable()
            }else {
                reachabilityReachable()
            }
        }
    }
    //HandleReachabilityChanged
    func reachabilityReachable() {
        //subclass must override
        fatalError("BonFireBaseViewController Subclass Must Override")
    }
    func reachabilityUnreachable() {
        //subclass must override
        UtilityFunction.shared.alert(.internetUnreachable)
    }
    
    func handlePhotoSelector() {
        let selectAlert = UIAlertController(title: "Pick A Photo", message: nil, preferredStyle: .actionSheet)
        let fromLibrary = UIAlertAction(title: "From Phoho Library", style: .default) { (_) in
            self.pscopePhoto.show({ (finished, results) in
                if finished, results.first?.status == .authorized{
                    self.prestentImagePickerControllerWithType(.photoLibrary)
                }
            }, cancelled: nil)
        }
        let fromCamera = UIAlertAction(title: "Camera", style: .default) { (_) in
            self.pscopeCamera.show({ (finished, results) in
                if finished, results.first?.status == .authorized{
                    self.prestentImagePickerControllerWithType(.camera)
                }
            }, cancelled: nil)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        selectAlert.addAction(fromLibrary)
        selectAlert.addAction(fromCamera)
        selectAlert.addAction(cancel)
        self.present(selectAlert, animated: true, completion: nil)
    }
    
    private func prestentImagePickerControllerWithType(_ soruceType:UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = soruceType
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    //UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
