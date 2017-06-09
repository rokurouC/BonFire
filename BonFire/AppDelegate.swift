//
//  AppDelegate.swift
//  BonFire
//
//  Created by 建達 陳 on 2017/4/24.
//  Copyright © 2017年 ChienTa Chen. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuthUI
import ReachabilitySwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var reachability: Reachability?
    var internetAlert:UIAlertController?
    var firDatabaseRef:DatabaseReference!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Use Firebase library to configure APIs
        FirebaseApp.configure()
        Database.database().isPersistenceEnabled = true
        firDatabaseRef = Database.database().reference()
        return true
    }
    
    func startReachabilityNotifier() {
        reachability = Reachability()
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
        reachability = nil
    }
    
    func reachabilityChanged(_ note: Notification) {
        if let reachability = note.object as? Reachability {
            if !reachability.isReachable {
                UtilityFunction.shared.unreachableAlert()
            }
        }
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        if let sourceApplication = options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String? {
            if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
                return true
            }
        }
        // other URL handling goes here.
        return false
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        stopReachabilityNotifier()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        startReachabilityNotifier()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

