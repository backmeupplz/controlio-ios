//
//  PushNotificationsManager.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 08/06/15.
//  Copyright (c) 2015 Borodutch Studio LLC. All rights reserved.
//

import Foundation

class PushNotificationsManager {
    
    // MARK: - Singleton -
    
    static let sharedInstance = PushNotificationsManager()
    
    // MARK: - Variables -
    
    var pushToken: String?
    
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
            pushToken = nil
        }
    }
}