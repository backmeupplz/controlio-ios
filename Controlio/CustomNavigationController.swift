//
//  CustomNavigationController.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 13/05/16.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit

class CustomNavigationController: UINavigationController {
    
    // MARK: - Status Bar -
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}
