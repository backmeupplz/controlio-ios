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
import Stripe
import Material
import IQKeyboardManagerSwift
#if DEBUG
import SimulatorStatusMagic
#endif

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
        Server.fetchErrorsLocalizations()
        Appearance.setup()
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().enableAutoToolbar = false
        
        return true
    }
    
    // MARK: - Private Functions -
    
    fileprivate func checkIfUITests() {
        if UserDefaults.standard.bool(forKey: "FASTLANE_SNAPSHOT") {
            if let bundle = Bundle.main.bundleIdentifier {
                UserDefaults.standard.removePersistentDomain(forName: bundle)
            }
//            UIView.setAnimationsEnabled(false)
            #if DEBUG
            SDStatusBarManager.sharedInstance().enableOverrides()
            #endif
        }
    }
    
    fileprivate func configureVCs() {
        window = UIWindow(frame: Screen.bounds)
        window!.rootViewController = AppSnackbarController(rootViewController: R.storyboard.login.instantiateInitialViewController()!)
        window!.makeKeyAndVisible()
    }
    
    fileprivate func configureStripe() {
        STPPaymentConfiguration.shared().publishableKey = "pk_live_brweKfRgeq7Fe3PH4FScn99S"
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
    
    func handle(url: URL) {
        guard let token = getToken(from: url) else { return }
        guard let topController = UIApplication.topViewController() else { return }
        
        if url.path == "/public/resetPassword" {
            Router(topController).presentChangePassword(with: token, type: .reset)
        } else if url.path == "/public/setPassword" {
            Router(topController).presentChangePassword(with: token, type: .set)
        } else if url.path == "/magic" {
            guard let hud = MBProgressHUD.show() else { return }
            Server.loginMagicLink(token: token)
            { error in
                hud.hide(animated: true)
                if let error = error {
                    topController.snackbarController?.show(error: error.domain)
                } else {
                    self.post(notification: .shouldLogin)
                }
            }
        }
    }
    
    func getToken(from url: URL) -> String? {
        let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []
        var queryItemsDictionary = [String: String]()
        
        for item in queryItems {
            queryItemsDictionary[item.name] = item.value
        }
        return queryItemsDictionary["token"]
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
        handle(url: url)
        
        return true
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            if let url = userActivity.webpageURL {
                handle(url: url)
            }
        }
        return true
    }
}
