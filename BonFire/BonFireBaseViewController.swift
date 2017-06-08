//
//  BonFireBaseViewController.swift
//  BonFire
//
//  Created by 建達 陳 on 2017/5/8.
//  Copyright © 2017年 ChienTa Chen. All rights reserved.
//

import UIKit
import PermissionScope

class BonFireBaseViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let pscopeCamera:PermissionScope = {
        let pscope = PermissionScope()
        pscope.headerLabel.text = "Need Camera"
        pscope.bodyLabel.text = "📷"
        pscope.addPermission(CameraPermission(), message: "For taking pictures by camera, please enable BonFire to use it!")
        return pscope
    }()
    let pscopePhoto:PermissionScope = {
        let pscope = PermissionScope()
        pscope.headerLabel.text = "Need Photos"
        pscope.bodyLabel.text = "🏞"
        pscope.addPermission(PhotosPermission(), message: "For picking photos from library, please enable BonFire to use it!")
        return pscope
    }()
    
    var currentUser:BonFireUser?
    
    
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
    
    func prestentImagePickerControllerWithType(_ soruceType:UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = soruceType
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
}
