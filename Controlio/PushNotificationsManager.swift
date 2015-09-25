//
//  PushNotificationsManager.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 08/06/15.
//  Copyright (c) 2015 Borodutch Studio LLC. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class PushNotificationsManager {
    
    // MARK: - Singleton -
    
    static let sharedInstance = PushNotificationsManager()
    
    // MARK: - Variables -
    
    var pushToken: String?
    var projectToShow: ProjectObject?
    
    // MARK: - Public methods -
    
    func registerPushToken(token: NSString) {
        pushToken = String(token)
    }
    
    func sendPushTokenToServer() {
        if (pushToken != nil) {
            ServerManager.sharedInstance.addPushTokenToServer(pushToken!)
        }
    }
    
    func logout() {
        if (pushToken != nil) {
            ServerManager.sharedInstance.deletePushTokenFromServer(pushToken!)
        }
    }
    
    func appLaunchedWithOptions(launchOptions: [NSObject: AnyObject]?) {
        if let launchOpts = launchOptions {
            let notificationPayload = launchOpts[UIApplicationLaunchOptionsRemoteNotificationKey] as? [NSObject : AnyObject]
            if (notificationPayload != nil) {
                handlePush(notificationPayload!, launch: true)
            }
        }
    }
    
    func appReceivedRemoteNotification(userInfo: [NSObject : AnyObject]) {
        if (UIApplication.sharedApplication().applicationState != .Active) {
            handlePush(userInfo, launch: false)
        }
    }
    
    func handlePush(push:[NSObject : AnyObject], launch:Bool) {
        
        let token = NSUserDefaults.standardUserDefaults().objectForKey(UDToken) as? String
        if (token != nil) {
            if (launch) {
                projectToShow = ProjectObject.convertJsonToObject(JSON(push["project"]!))
            } else {
                let navCont = UIApplication.sharedApplication().keyWindow?.rootViewController as! UINavigationController
                navCont.popToViewController(navCont.viewControllers[1] , animated: false)
                let topVC = navCont.topViewController as! ProjectListViewController
                topVC.performSegueWithIdentifier("SegueToReports", sender: ProjectObject.convertJsonToObject(JSON(push["project"]!)))
            }
        }
        
    }
    
    func showTestAlert() {
        let alert = UIAlertView(title: "Why?", message: "", delegate: nil, cancelButtonTitle: "ok")
        alert.show()
    }
}