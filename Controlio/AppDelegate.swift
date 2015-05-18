//
//  AppDelegate.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 17/05/15.
//  Copyright (c) 2015 Borodutch Studio LLC. All rights reserved.
//

import UIKit
//import GoogleAnalytics_iOS_SDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // MARK: - Variables -
    
    var window: UIWindow?

    // MARK: - App Life Cycle -
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        setupAnalytics()
        
        return true
    }
    
    // MARK: - General Methods -
    
    func setupAnalytics() {
//        GAI.sharedInstance().trackerWithTrackingId(googleTrackingID)
    }
}

