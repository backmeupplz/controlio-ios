//
//  MainViewController.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 09/03/16.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit

class MainViewController: UITabBarController {
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBar.tintColor = UIColor.controlioGreen()
    }
}
