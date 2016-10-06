 //
//  AppDelegate.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 09/03/16.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit
import UserNotifications
//import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: - Variables -
    
    var window: UIWindow?
    
    // MARK: - Application Life Cycle -

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        setupKeyboard()
        PopupNotification.setup()
        S3.setup()
        setupPushNotifications(application: application)
        
        return true
    }
    
    // MARK: - Private Functions -
    
    fileprivate func setupKeyboard() {
//        IQKeyboardManager.sharedManager().enable = true
//        IQKeyboardManager.sharedManager().enableAutoToolbar = false
    }
    
    fileprivate func setupPushNotifications(application: UIApplication) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            if let error = error {
                print(error)
            }
        }
        application.registerForRemoteNotifications()
    }
    
    // MARK: - Push Notifications Delegate -
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        Server.pushNotificationsToken = deviceTokenString
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error)
    }
    
    // MARK: - Universal links -
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            if let url = userActivity.webpageURL {
                let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []
                var queryItemsDictionary = [String: String]()
                
                for item in queryItems {
                    queryItemsDictionary[item.name] = item.value
                }
                let userId = queryItemsDictionary["userid"]
                let token = queryItemsDictionary["token"]
                
                print(userId)
                print(token)
            }
        }
        return true
    }
}

