//
//  FireBonFireView.swift
//  BonFire
//
//  Created by 建達 陳 on 2017/4/28.
//  Copyright © 2017年 ChienTa Chen. All rights reserved.
//

import UIKit

protocol FireBonFireViewDelegate:class {
    func didFinishedFireABonFire(campsiteName:String, profileImage:UIImage)
    func didCancelFireABonFire()
    func didTapProfileImageView()
}

class FireBonFireView: UIView,UITextFieldDelegate {
    //MARK: - IBOutlet
    @IBOutlet private weak var outsideView: UIView!
    @IBOutlet weak var insideView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var campSiteNameTextField: UITextField!

    weak var delegate:FireBonFireViewDelegate?
    var originalFrameYposition:CGFloat?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profileImageView.layer.cornerRadius = profileImageView.frame.width/2
        insideView.layer.cornerRadius = 5
        subscribeToKeyboardNotifications()
    }
    
    deinit {
        unsubscribeFromKeyboardNotifications()
    }
    //MARK: - IBAction
    @IBAction private func didTapImageView(_ sender: Any) {
        delegate?.didTapProfileImageView()
    }
    
    @IBAction private func cancel(_ sender: Any) {
        self.endEditing(true)
        delegate?.didCancelFireABonFire()
    }
    
    @IBAction private func fire(_ sender: Any) {
        delegate?.didFinishedFireABonFire(campsiteName: campSiteNameTextField.text!, profileImage: profileImageView.image!)
    }
    
    
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        campSiteNameTextField.placeholder = ""
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        originalFrameYposition = self.frame.origin.y
        return true
    }
    @IBAction private func editingChange(_ sender: Any) {
        okButton.isEnabled = campSiteNameTextField.text!.characters.count > 0
    }
}
//MARK: - Keyboard show/hide handler
extension FireBonFireView {
    
    @objc private func keyboardWillShow(_ notification:Notification) {
        self.frame.origin.y = originalFrameYposition! - getKeyboardHeight(notification)
    }
    @objc private func keyboardWillHide(_ notification:Notification) {
        self.frame.origin.y = originalFrameYposition!
    }
    
    private func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
        
    }
    
    fileprivate func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    fileprivate func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
}



