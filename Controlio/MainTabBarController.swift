//
//  MainController.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 09/03/16.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class MainTabBarController: ASTabBarController {
    
    // MARK: - View Controller Life Cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let newProjectController = R.storyboard.main.newProjectController(),
            let supportController = R.storyboard.main.supportController(),
            let settingsController = R.storyboard.main.settingsController()
            else { return }
        
        viewControllers = [
            navigationController(with: ProjectsController(),
                                 image: R.image.projects(),
                                 title: NSLocalizedString("Projects", comment: "tabbar title")),
            navigationController(with: newProjectController,
                                 image: R.image.newProject(),
                                 title: NSLocalizedString("New Project", comment: "tabbar title")),
            navigationController(with: supportController,
                                 image: R.image.support(),
                                 title: NSLocalizedString("Support", comment: "tabbar title")),
            navigationController(with: settingsController,
                                 image: R.image.settings(),
                                 title: NSLocalizedString("Settings", comment: "tabbar title")),
        ]
        
        tabBar.tintColor = UIColor.controlioGreen
    }
    
    // MARK: - Private functions -
    
    func navigationController(with rootVC: UIViewController, image: UIImage?, title: String) -> UINavigationController {
        rootVC.title = title
        let vc = NavigationController(rootViewController: rootVC)
        vc.tabBarItem.image = image
        return vc
    }
    
    // MARK: - Status Bar -
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
}
