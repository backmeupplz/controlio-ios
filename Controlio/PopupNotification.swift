//
//  PopupNotificationManager.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 06/05/16.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit
import JDStatusBarNotification

class PopupNotification: NSObject {
    
    // MARK: - Public Functions -
    
    class func show(notification: String) {
        let alert = UIAlertController(title: "Ouch!", message: notification, preferredStyle: .alert)
        alert.addDefaultAction("Ok!") { 
            // do nothing
        }
        UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
    }
}
