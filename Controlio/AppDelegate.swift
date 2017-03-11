 //
//  AppDelegate.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 09/03/16.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit
import UserNotifications
import MBProgressHUD
import CLTokenInputView
import Stripe
import Material

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: - Variables -
    
    var window: UIWindow?
    
    // MARK: - Application Life Cycle -

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        configureVCs()
        configureStripe()
        S3.setup()
        setupPushNotifications(application: application)
        FeatureList.fetchFeatureList()
        
        return true
    }
    
    // MARK: - Private Functions -
    
    fileprivate func configureVCs() {
        window = UIWindow(frame: Screen.bounds)
        window!.rootViewController = AppSnackbarController(rootViewController: R.storyboard.login.instantiateInitialViewController()!)
        window!.makeKeyAndVisible()
    }
    
    fileprivate func configureStripe() {
        STPPaymentConfiguration.shared().publishableKey = "pk_test_QUk0bgtsbIfR67SVr0EHnIpx"
        STPPaymentConfiguration.shared().companyName = "Controlio"
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
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        login(with: url)
        
        return true
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            if let url = userActivity.webpageURL {
                login(with: url)
            }
        }
        return true
    }
    
    func login(with url: URL) {
        
        let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []
        var queryItemsDictionary = [String: String]()
        
        for item in queryItems {
            queryItemsDictionary[item.name] = item.value
        }
        let userId = queryItemsDictionary["userid"]
        let token = queryItemsDictionary["token"]
        
        guard let userIdUnwrapped = userId, let tokenUnwrapped = token else {
            return
        }
        
        guard let topController = UIApplication.topViewController() else { return }
        guard let hud = MBProgressHUD.show() else { return }
        Server.loginMagicLink(userid: userIdUnwrapped, token: tokenUnwrapped)
        { error in
            hud.hide(animated: true)
            if let error = error {
                PopupNotification.show(notification: error.domain)
            } else {
                Router(topController).showMain()
            }
        }
    }
}

