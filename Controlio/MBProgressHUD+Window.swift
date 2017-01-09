//
//  MBProgressHUD+Window.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 09/01/2017.
//  Copyright © 2017 Nikita Kolmogorov. All rights reserved.
//

import UIKit
import MBProgressHUD

extension MBProgressHUD {
    class func show() -> MBProgressHUD? {
        if let app = UIApplication.shared.delegate as? AppDelegate,
            let window = app.window {
            return MBProgressHUD.showAdded(to: window, animated: false)
        }
        return nil
    }
}
