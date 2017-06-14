//
//  ChatViewController.swift
//  BonFire
//
//  Created by 建達 陳 on 2017/4/25.
//  Copyright © 2017年 ChienTa Chen. All rights reserved.
//

import UIKit
import Firebase

class ChatViewController: BonFireBaseViewController, UITableViewDelegate, UITableViewDataSource {
    //MARK: - IBOutlet
    @IBOutlet private weak var chatTableView: UITableView!
    @IBOutlet fileprivate weak var chatTextView: UITextView!
    @IBOutlet fileprivate weak var placeholderLabel: UILabel!
    @IBOutlet private weak var textContentView: UIView!
    @IBOutlet weak var backButtonItem: UIBarButtonItem!
    //MARK: - Property
    fileprivate var textContentViewMaxHeight:CGFloat = 150
    fileprivate var textViewSumOfTopAndBottomAnchorstoTextContextView:CGFloat = 16
    
    var messages = [Message]()
    var currentCampsite:Campsite?
    
    private var _campsiteLastMessageHandle: DatabaseHandle!
    private var campsitesLastMessageRef:DatabaseReference?
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        chatTextView.keyboardDismissMode = .none
        chatTableView.estimatedRowHeight = 1152
        chatTableView.rowHeight = UITableViewAutomaticDimension
        chatTableView.alwaysBounceVertical = true
        chatTextView.layer.cornerRadius = 3
        configureDatabase()
        getMessagesAndListenLastMessage()
        chatTableView.register(ImageMessageTableViewCell.self, forCellReuseIdentifier: "imageMessageCell")
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
        updateUserCampsiteLastMessageAndBadge()
    }
    
    override func reachabilityReachable() {
        //Must override, but to be determined
    }
    
    deinit {
        campsitesLastMessageRef?.removeObserver(withHandle: _campsiteLastMessageHandle)
    }
    
    private func updateUserCampsiteLastMessageAndBadge() {
        if let user = currentUser, var campsite = currentCampsite {
            campsite.badgeNumber = 0
            if messages.count > 0 , let lastMessage = messages.last{
                campsite.lastMessage = lastMessage
            }
            FirebaseClient.sharedInstance.updateUserCampsiteLastMessageAndBadge(user: user, campsite: campsite, isViewed: true, completion: { (isUpdatedSuccess) in
                if isUpdatedSuccess {
                    print("UpdatedSuccess")
                }
            })
        }
    }
    
    private func configureDatabase() {
        campsitesLastMessageRef = (UIApplication.shared.delegate as! AppDelegate).firDatabaseRef.child(Constants.FIRDatabaseConstants.campsites).child(currentCampsite!.id).child(Constants.FIRDatabaseConstants.Campsite.lastmessage)
    }
    
    private func getMessagesAndListenLastMessage() {
        FirebaseClient.sharedInstance.getMessagesOfCampsiteWithId(user: currentUser!, campsiteId: currentCampsite!.id) { [unowned self](messages) in
            guard messages != nil else {
                self._campsiteLastMessageHandle = FirebaseClient.sharedInstance.listenLastMessageOfCampsiteWithId(user: self.currentUser!, campsiteId: self.currentCampsite!.id, completion: { (message) in
                    guard message != nil else { return }
                    self.messages.append(message!)
                    self.chatTableView.insertRows(at: [IndexPath(row: self.messages.count - 1, section: 0)], with: .automatic)
                    self.scrollToBottomMessage()
                })
                return
            }
            self.messages = messages!
            DispatchQueue.main.async {
                self.chatTableView.reloadData()
                self.scrollToBottomMessage()
                self._campsiteLastMessageHandle = FirebaseClient.sharedInstance.listenLastMessageOfCampsiteWithId(user: self.currentUser!, campsiteId: self.currentCampsite!.id, completion: { [unowned self] (message) in
                    guard message != nil else { return }
                    self.messages.append(message!)
                    self.chatTableView.insertRows(at: [IndexPath(row: self.messages.count - 1, section: 0)], with: .automatic)
                    DispatchQueue.main.async {
                        self.scrollToBottomMessage()
                    }
                })
            }
        }
    }
    //MARK: - IBAction
    @IBAction private func sendMessage(_ sender: Any) {
        chatTextView.resignFirstResponder()
        guard chatTextView.text.characters.count > 0 else {
            return
        }
        FirebaseClient.sharedInstance.addTextMessageToCampsite(user: currentUser!, text: chatTextView.text, campsiteId: currentCampsite!.id)
        chatTextView.text = ""
        placeholderLabel.isHidden = false
        
    }
    
    @IBAction private func sendImage(_ sender: Any) {
        guard let isReachable = reachability?.isReachable, isReachable else {
            //Can't sent image without connection, featurenot open yet
            UtilityFunction.shared.alert(.unableSendImageMessageWithoutConnection)
            return
        }
        handlePhotoSelector()
    }
    
    @IBAction private func back(_ sender: Any) {
        if let NVC = self.navigationController, let vc = self.navigationController?.viewControllers.first as? CampsiteListsTableViewController {
            vc.nowPresentedCampsite = nil
            NVC.popViewController(animated: true)
        }
    }
    @IBAction private func tapTableview(_ sender: Any) {
        chatTextView.resignFirstResponder()
    }
    
    private func scrollToBottomMessage() {
        if messages.count == 0 { return }
        let bottomMessageIndex = IndexPath(row: chatTableView.numberOfRows(inSection: 0) - 1, section: 0)
        chatTableView.scrollToRow(at: bottomMessageIndex, at: .none, animated: false)
        
    }
    //MARK: - TableView Data Source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let message = messages[indexPath.row]
        if let _ = message.messageImageUrl, message.userId == currentUser!.uId {
            let cell = ImageMessageTableViewCell(style: .default, reuseIdentifier: "imageMessageCell", placeholderSize: message.messageImageSize!, sender: .user, message: message)
            cell.isUserInteractionEnabled = false
            return cell
            
        }
        if let _ = message.messageImageUrl, message.userId != currentUser!.uId {
            let cell = ImageMessageTableViewCell(style: .default, reuseIdentifier: "imageMessageCell", placeholderSize: message.messageImageSize!, sender: .others, message: message)
            cell.isUserInteractionEnabled = false
            return cell
            
        }
        
        if message.userId == currentUser!.uId {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserChatTableViewCell", for: indexPath) as! UserChatTableViewCell
            cell.setupWithData(message: message)
            cell.isUserInteractionEnabled = false
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "OthersChatTableViewCell", for: indexPath) as! OthersChatTableViewCell
            cell.setupWithData(message: message)
            cell.isUserInteractionEnabled = false
            return cell
        }
    }
}

//MARK: - UITextView delegate
extension ChatViewController:UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if !placeholderLabel.isHidden {
            placeholderLabel.isHidden = true
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        placeholderLabel.isHidden = textView.text.characters.count > 0
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let fixedWidth = textView.frame.size.width
        let newHeight = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude)).height
        chatTextView.isScrollEnabled = newHeight + textViewSumOfTopAndBottomAnchorstoTextContextView >= textContentViewMaxHeight
        
    }
}


//MARK: - Keyboard show/hide handler
extension ChatViewController {
    
    fileprivate func subscribeToKeyboardNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    @objc fileprivate func adjustForKeyboard(notification: Notification) {
        let userInfo = notification.userInfo!
        
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == Notification.Name.UIKeyboardWillHide {
            self.view.frame.origin.y = 0
        } else {
            self.view.frame.origin.y = -keyboardViewEndFrame.height
        }
    }
    
    fileprivate func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
}

extension ChatViewController {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let editImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            FirebaseClient.sharedInstance.addImageMessageToCampsite(user: currentUser!, image: resize(image: editImage), campsiteId: currentCampsite!.id, quality: 0.8)
        }else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            FirebaseClient.sharedInstance.addImageMessageToCampsite(user: currentUser!, image: resize(image: originalImage), campsiteId: currentCampsite!.id, quality: 0.8)
        }
        dismiss(animated: true, completion: nil)
    }
    
    //TEST
    private func resize(image:UIImage) -> UIImage {
        let originalWidth = image.size.width
        let originalHeight = image.size.height
        guard max(originalWidth, originalHeight) > 1920 else {
            return image
        }
        var newSize: CGSize
        if originalWidth > originalHeight {
            newSize = CGSize(width: 1920, height: originalHeight * (1920/originalWidth))
        }else if originalHeight > originalWidth {
            newSize = CGSize(width: originalWidth * (1920/originalHeight), height: 1920)
        }else {
            newSize = CGSize(width: 1080, height: 1080)
        }
        UIGraphicsBeginImageContext(newSize)
        image.draw(in: CGRect(origin: CGPoint(x: 0, y: 0) , size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}
extension ChatViewController:CampsiteListVCDelegate {
    func CampsiteListsTableViewController(didUpdateSumBadge badge: Int) {
        guard badge > 0 else {
            DispatchQueue.main.async {
                self.backButtonItem.title = "<"
            }
            return
        }
        DispatchQueue.main.async {
            self.backButtonItem.title = "< \(String(badge))"
        }
    }
}

