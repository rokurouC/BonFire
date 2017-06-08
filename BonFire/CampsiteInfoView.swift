//
//  CampsiteInfoView.swift
//  BonFire
//
//  Created by 建達 陳 on 2017/5/2.
//  Copyright © 2017年 ChienTa Chen. All rights reserved.
//

import UIKit

protocol CampsiteInfoViewDelegate:class {
    func didEnterCampsite()
    func didCancel()
}
class CampsiteInfoView: UIView {
    //MARK: - IBOutlet
    @IBOutlet weak var ownerNameLabel: UILabel!
    @IBOutlet weak var enterButton: UIButton!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var campsiteNameLabel: UILabel!
    @IBOutlet weak var campsiteImageView: UIImageView!
    @IBOutlet weak var ownerImageView: UIImageView!
    weak var delegate:CampsiteInfoViewDelegate?
    //MARK: - IBAction
    @IBAction private func enterCampsite(_ sender: Any) {
        delegate?.didEnterCampsite()
    }

    @IBAction private func didCancel(_ sender: Any) {
        delegate?.didCancel()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        campsiteImageView.layer.cornerRadius = campsiteImageView.frame.width/2
        ownerImageView.layer.cornerRadius = ownerImageView.frame.width/2
    }
}
