//
//  SignInViewController.swift
//  BonFire
//
//  Created by 建達 陳 on 2017/4/27.
//  Copyright © 2017年 ChienTa Chen. All rights reserved.
//

import UIKit
import FirebaseAuthUI
@objc(SignInViewController)
class SignInViewController: FUIAuthPickerViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let rect = CGRect(x: self.view.bounds.size.width/2, y: 8, width: 20, height: 20)
        let label = UILabel(frame: rect)
        label.textAlignment = .center
        label.text = "Welcome to BonFire"
        label.sizeToFit()
        self.navigationItem.titleView = label
    }
}
