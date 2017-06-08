//
//  UserInfoEditView.swift
//  BonFire
//
//  Created by 建達 陳 on 2017/5/7.
//  Copyright © 2017年 ChienTa Chen. All rights reserved.
//

import UIKit
protocol UserInfoEditViewDelegate:class {
    func userInfoEditViewInfoDidCreating(info:InfoStruct)
    func userInfoEditViewInfoDidSave(info:InfoStruct)
    func userInfoEditViewAvatarImageViewDidTap()
    func userInfoEditViewDidCancel()
    func userInfoEditViewNameEmptyAlert()
}
enum InfoStatus {
    case Creating
    case Editing
    case Viewing
    
}
struct InfoStruct {
    let displayName:String
    let about:String
    let avatar:UIImage
}
class UserInfoEditView: UIView {
    //MARK: - IBOutlet
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet private weak var nameTextField: UITextField!
    @IBOutlet weak var aboutTextView: UITextView!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet private weak var cancelButtton: UIButton!
    @IBOutlet private weak var saveOrEditButton: UIButton!
    @IBOutlet weak var insideView: UIView!
    @IBOutlet private weak var backgroundView: UIView!
    //MARK: - Property
    weak var delegate:UserInfoEditViewDelegate?
    var maxNumberOfCharacters = 200
    var infoStatus:InfoStatus = .Viewing {
        didSet{
            switch infoStatus {
            case .Editing:
                enableUI(true)
                cancelButtton.isHidden = false
                saveOrEditButton.setTitle("SAVE", for: .normal)
                break
            case .Viewing:
                enableUI(false)
                cancelButtton.isHidden = false
                saveOrEditButton.setTitle("Edit", for: .normal)
                break
            case .Creating:
                enableUI(true)
                cancelButtton.isHidden = true
                saveOrEditButton.setTitle("SAVE", for: .normal)
                break
            }
        }
    }
    
    //MARK: - IBAction
    @IBAction private func avatarDidTap(_ sender: UITapGestureRecognizer) {
        delegate?.userInfoEditViewAvatarImageViewDidTap()
    }
    @IBAction private func cancel(_ sender: Any) {
        delegate?.userInfoEditViewDidCancel()
    }
    @IBAction private func saveOrEdit(_ sender: UIButton) {
        switch sender.currentTitle! {
        case "SAVE":
            guard let count = nameTextField.text?.characters.count, count > 0 else {
                delegate?.userInfoEditViewNameEmptyAlert()
                return
            }
            if infoStatus == .Creating {
                let info = InfoStruct(displayName: nameTextField.text!, about: aboutTextView.text, avatar: avatarImageView.image!)
                delegate?.userInfoEditViewInfoDidCreating(info: info)
            }else if infoStatus == .Editing {
                let info = InfoStruct(displayName: nameTextField.text!, about: aboutTextView.text, avatar: avatarImageView.image!)
                delegate?.userInfoEditViewInfoDidSave(info: info)
            }
//            infoStatus = .Viewing
        case "EDIT":
            infoStatus = .Editing
        default:
            break
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        countLabel.text = "\(aboutTextView.text.characters.count)/\(maxNumberOfCharacters)"
        aboutTextView.layer.cornerRadius = 5
        insideView.layer.cornerRadius = 5
        avatarImageView.layer.cornerRadius = avatarImageView.frame.width/2
        subscribeToKeyboardNotifications()
    }
    
    deinit {
        unsubscribeFromKeyboardNotifications()
    }
    private func enableUI(_ enable:Bool) {
        avatarImageView.isUserInteractionEnabled = enable
        nameTextField.isUserInteractionEnabled = enable
        aboutTextView.isUserInteractionEnabled = enable
    }

}

extension UserInfoEditView: UITextFieldDelegate {
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension UserInfoEditView:UITextViewDelegate {

    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        
        if textView.text.characters.count + text.characters.count > maxNumberOfCharacters {
            return false
        }
        return true
    }
    func textViewDidChange(_ textView: UITextView) {
        countLabel.text = "\(aboutTextView.text.characters.count)/\(maxNumberOfCharacters)"
    }
}


extension UserInfoEditView {
    //MARK: - Keyboard show/hide handler
    @objc private func keyboardWillShow(_ notification:Notification) {
        let bottomSpace = UIScreen.main.bounds.height - (self.insideView.frame.origin.y + self.insideView.frame.height)
        self.frame.origin.y = -(getKeyboardHeight(notification) - bottomSpace)
    }
    @objc private func keyboardWillHide(_ notification:Notification) {
        self.frame.origin.y = 0
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
