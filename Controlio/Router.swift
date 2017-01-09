//
//  Router.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 09/03/16.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit

class Router {
    
    // MARK: - Variables -
    
    private var controller: UIViewController!
    
    // MARK: - Object Life Cycle -
    
    convenience init(_ _controller: UIViewController) {
        self.init()
        
        controller = _controller
    }
    
    // MARK: - Public Functions -
    
    func showLogin() {
        show(vc: R.storyboard.login.loginViewController())
    }
    
    func showRecovery() {
        show(vc: R.storyboard.login.recoveryViewController())
    }
    
    func showMain(animated: Bool = true) {
        show(vc: R.storyboard.main.mainController(), animated: animated)
    }
    
    func show(project: Project, delegate: ProjectControllerDelegate? = nil) {
        
    }
    
    // MARK: - Private Functions -
    
    fileprivate func show(vc: UIViewController?, animated: Bool = true) {
        guard let vc = vc else { return }
        
        if animated {
            controller.show(vc, sender: controller)
        } else {
            controller.navigationController?.viewControllers.append(vc)
        }
    }
}
