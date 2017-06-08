//
//  CompsiteListsTableViewController.swift
//  BonFire
//
//  Created by 建達 陳 on 2017/4/30.
//  Copyright © 2017年 ChienTa Chen. All rights reserved.
//

import UIKit
import Firebase

protocol CampsiteListVCDelegate:class {
    func CampsiteListsTableViewController(didUpdateSumBadge badge:Int)
}

class CampsiteListsTableViewController: UITableViewController {
    //MARK: - Property
    weak var delegate:CampsiteListVCDelegate?
    var currentUser: BonFireUser?
    var campsites = [Campsite]()
    var nowPresentedCampsite:Campsite?
    
    var databaseRefsAndHandles = [(DatabaseReference,DatabaseHandle)]()
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Campsites"
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableViewAutomaticDimension
        getAllCampsitesOfUserAdd()
        checkIfPushToChatVCIsNeed()
        
    }
    
    deinit {
        removeAllObserver()
    }
    
    private func checkIfPushToChatVCIsNeed() {
        if nowPresentedCampsite != nil {
            pushToChatVC(campsite: nowPresentedCampsite!, animated: false)
            nowPresentedCampsite?.badgeNumber = 0
            if let user = currentUser, let campsite = nowPresentedCampsite {
                FirebaseClient.sharedInstance.updateUserCampsiteLastMessageAndBadge(user: user, campsite: campsite, isViewed: true, completion: { (isUpdatedSuccess) in
                    if !isUpdatedSuccess {
                        print("update failed!")
                    }
                })
            }
            
        }
    }
    
    private func removeAllObserver() {
        for databaseRefAndHandle in databaseRefsAndHandles {
            databaseRefAndHandle.0.removeObserver(withHandle: databaseRefAndHandle.1)
        }
    }
    
    private func showNoCampsitesAlert() {
        let alert = UIAlertController(title: "Hey", message: "You haven't joined any campsite yet, how about going back to map and choose or create one?", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "CANCEL", style: .default, handler: nil)
        let OK = UIAlertAction(title: "OK", style: .default) { (_) in
            if let NVC = self.navigationController {
                NVC.dismiss(animated: true, completion: nil)
            }
        }
        alert.addAction(cancel)
        alert.addAction(OK)
        self.present(alert, animated: true, completion: nil)
    }
    
    private func getAllCampsitesOfUserAdd() {
        FirebaseClient.sharedInstance.getAllCampsitesOfUser(user: currentUser!) { (campsites) in
            guard campsites != nil else {
                self.showNoCampsitesAlert()
                return
            }
            self.campsites = campsites!
            //test
            self.delegateUpdateUIWithBadgeSum()
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.observeAllCampsiteLastMessageAdd()
            }
        }
    }
    
    private func observeAllCampsiteLastMessageAdd() {
        databaseRefsAndHandles = FirebaseClient.sharedInstance.listenUserCampsitesMessageAdd(campsites: campsites, completion: { [unowned self](campsiteReturn) in
            guard campsiteReturn != nil else {
                return
            }
            for (index,campsite) in self.campsites.enumerated() {
                
                if campsiteReturn!.id == campsite.id {
                    var isViewed:Bool?
                    var campsiteCopy = campsite
                    campsiteCopy.lastMessage = campsiteReturn?.lastMessage
                    if campsiteCopy.id != self.nowPresentedCampsite?.id {
                        campsiteCopy.badgeNumber += 1
                        isViewed = false
                    }else {
                        campsiteCopy.badgeNumber = 0
                        isViewed = true
                    }
                    FirebaseClient.sharedInstance.updateUserCampsiteLastMessageAndBadge(user: self.currentUser!, campsite: campsiteCopy, isViewed: isViewed!, completion: { (isUpdateSuccess) in
                        if isUpdateSuccess {
                            self.campsites.remove(at: index)
                            self.campsites.insert(campsiteCopy, at: 0)
                            //test
                            self.delegateUpdateUIWithBadgeSum()
                            
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
                    })
                }
            }
        })
    }
    
    
    //MARK: - IBAction
    @IBAction private func back(_ sender: Any) {
        if let NVC = self.navigationController {
            NVC.dismiss(animated: true, completion: nil)
        }
    }
    
    //MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return campsites.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let campsite = campsites[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "CampsiteListTableViewCell", for: indexPath) as! CampsiteListTableViewCell
        cell.setup(campsite: campsite)
        return cell
    }
    
    //MARK: - Table delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let campsite = campsites[indexPath.row]
        nowPresentedCampsite = campsite
        pushToChatVC(campsite: campsite, animated: true)
        resetCampsiteBadgeAndUpdateTableRowCell(campsite: campsite, indexPath: indexPath )
    }
    private func pushToChatVC(campsite:Campsite, animated:Bool) {
        if let nc = self.navigationController, let user = self.currentUser {
            let chatVc = self.storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
            chatVc.title = campsite.name
            chatVc.currentCampsite = campsite
            chatVc.currentUser = user
            nowPresentedCampsite = campsite
            let badgeSum = self.campsites.reduce(0) {
                $0 + $1.badgeNumber
            }
            chatVc.backButtonItem.title = badgeSum == 0 ? "<" : "< \(String(badgeSum))"
            self.delegate = chatVc
            nc.pushViewController(chatVc, animated: animated)
        }
    }
    private func resetCampsiteBadgeAndUpdateTableRowCell(campsite:Campsite, indexPath:IndexPath) {
        var campsiteCopy = campsite
        campsiteCopy.badgeNumber = 0
        FirebaseClient.sharedInstance.updateUserCampsiteLastMessageAndBadge(user: currentUser!, campsite: campsiteCopy, isViewed: true) { (isUpdateSuccess) in
            if isUpdateSuccess {
                //update success replace Row cell
                self.campsites[indexPath.row] = campsiteCopy
                //test
                self.delegateUpdateUIWithBadgeSum()
                DispatchQueue.main.async {
                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            }
        }
    }

    private func delegateUpdateUIWithBadgeSum() {
        let badgeSum = self.campsites.reduce(0) {
            $0 + $1.badgeNumber
        }
        self.delegate?.CampsiteListsTableViewController(didUpdateSumBadge: badgeSum)
    }
    
    
}
