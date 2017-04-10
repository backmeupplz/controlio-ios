//
//  NavigationController.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 10/04/2017.
//  Copyright © 2017 Nikita Kolmogorov. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class NavigationController: ASNavigationController {
    // MARK: - Status Bar -
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
}
