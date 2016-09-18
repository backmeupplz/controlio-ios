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
    
    // MARK: - Private Class Variables -
    
    fileprivate static let controlioStyle = "controlioStyle"
    
    // MARK: - Public Functions -
    
    class func setup() {
        JDStatusBarNotification.addStyleNamed(controlioStyle) { style -> JDStatusBarStyle! in
            style?.barColor = UIColor.controlioViolet()
            style?.textColor = UIColor.white
            style?.font = UIFont(name: "SFUIText-Regular", size: 12)
            return style
        }
    }
    
    class func showNotification(_ text: String) {
        JDStatusBarNotification.show(withStatus: text, dismissAfter: 2.0, styleName: controlioStyle)
    }
}
