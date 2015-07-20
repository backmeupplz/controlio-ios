//
//  AppDelegate.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 17/05/15.
//  Copyright (c) 2015 Borodutch Studio LLC. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // MARK: - Variables -
    
    var window: UIWindow?

    // MARK: - App Life Cycle -
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        registerForNotifications(application)
        PushNotificationsManager.sharedInstance.appLaunchedWithOptions(launchOptions)
        
        return true
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let tokenChars = UnsafePointer<CChar>(deviceToken.bytes)
        var tokenString = ""
        for var i = 0; i < deviceToken.length; i++ {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
        
        PushNotificationsManager.sharedInstance.registerPushToken(tokenString)
        println("Registered for push notifications with token: \(tokenString)")
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        println("Failed to register for push notifications: \(error.localizedDescription)")
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        application.applicationIconBadgeNumber = 0
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        PushNotificationsManager.sharedInstance.appReceivedRemoteNotification(userInfo)
    }
    
    // MARK: - General Methods -
    
    func registerForNotifications(app: UIApplication) {
        let notificationTypes = UIUserNotificationType.Alert | UIUserNotificationType.Badge | UIUserNotificationType.Sound
        let settings = UIUserNotificationSettings(forTypes: notificationTypes, categories: nil)
        
        app.registerUserNotificationSettings(settings)
        app.registerForRemoteNotifications()
    }
}

