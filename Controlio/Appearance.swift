//
//  Appearance.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 08/04/2017.
//  Copyright © 2017 Nikita Kolmogorov. All rights reserved.
//

import UIKit
import Material

class Appearance {
    
    // MARK: - Public functions -
    
    class func setup() {
        setupNavigationController()
        setupTabBar()
    }
    
    // MARK: - Private functions -
    
    fileprivate class func setupNavigationController() {
        let navigationBarAppearace = UINavigationBar.appearance()
        
        navigationBarAppearace.tintColor = Color.white
        navigationBarAppearace.barTintColor = Color.controlioViolet
        navigationBarAppearace.titleTextAttributes = [NSForegroundColorAttributeName : Color.white]
        navigationBarAppearace.isOpaque = false
    }
    
    fileprivate class func setupTabBar() {
        let tabBarAppearance = UITabBarItem.appearance()
        
        tabBarAppearance.setTitleTextAttributes([NSForegroundColorAttributeName: Color.controlioGreen], for: .selected)
        tabBarAppearance.setTitleTextAttributes([NSForegroundColorAttributeName: Color.darkGray], for: .normal)
    }
}
