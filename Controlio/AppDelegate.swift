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
        checkIfUITests()
        configureVCs()
        configureStripe()
        S3.setup()
        setupPushNotifications(application: application)
        FeatureList.fetchFeatureList()
        
        return true
    }
    
    // MARK: - Private Functions -
    
    fileprivate func checkIfUITests() {
        if ProcessInfo.processInfo.arguments.contains("isUITesting") {
            if let bundle = Bundle.main.bundleIdentifier {
                UserDefaults.standard.removePersistentDomain(forName: bundle)
            }
        }
    }
    
    fileprivate func configureVCs() {
        window = UIWindow(frame: Screen.bounds)
        window!.rootViewController = AppSnackbarController(rootViewController: R.storyboard.login.instantiateInitialViewController()!)
        window!.makeKeyAndVisible()
    }
    
    fileprivate func configureStripe() {
        STPPaymentConfiguration.shared().publishableKey = "pk_test_MybaaRNvH9ndvmA5ty1atlGO"
        STPPaymentConfiguration.shared().companyName = "Controlio"
    }
    
    fileprivate func setupPushNotifications(application: UIApplication) {
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
                if let error = error {
                    print(error)
                }
            }
        } else {
            // Fallback on earlier versions
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
        let token = queryItemsDictionary["token"]
        
        guard let tokenUnwrapped = token else {
            return
        }
        
        guard let topController = UIApplication.topViewController() else { return }
        guard let hud = MBProgressHUD.show() else { return }
        Server.loginMagicLink(token: tokenUnwrapped)
        { error in
            hud.hide(animated: true)
            if let error = error {
                topController.snackbarController?.show(error: error.domain)
            } else {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ShouldLogin"), object: nil)
            }
        }
    }
}

