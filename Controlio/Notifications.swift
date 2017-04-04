//
//  Notifications.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 03/04/2017.
//  Copyright © 2017 Nikita Kolmogorov. All rights reserved.
//

import UIKit

extension Notification.Name {
    static let shouldLogin = Notification.Name("shouldLogin")
    static let projectCreated = Notification.Name("projectCreated")
    static let projectDeleted = Notification.Name("projectDeleted")
    static let projectArchivedChanged = Notification.Name("projectArchivedChanged")
}

extension NSObject {
    func subscribe(to notifications: [Notification.Name: Selector]) {
        for (notification, selector) in notifications {
            NotificationCenter.default.addObserver(self, selector: selector, name: notification, object: nil)
        }
    }
    func unsubscribe() {
        NotificationCenter.default.removeObserver(self)
    }
    func post(notification: Notification.Name, userInfo: [AnyHashable: Any]? = nil) {
        NotificationCenter.default.post(name: notification, object: nil, userInfo: userInfo)
    }
}
