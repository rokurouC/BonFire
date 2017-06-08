//
//  UIView.swift
//  BonFire
//
//  Created by 建達 陳 on 2017/5/2.
//  Copyright © 2017年 ChienTa Chen. All rights reserved.
//

import Foundation
import UIKit
extension UIView {
    class func instanceFromNib(nibName:String) -> UIView {
        return UINib(nibName: nibName, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
}
