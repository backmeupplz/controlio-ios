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
        showVC(R.storyboard.login.loginViewController())
    }
    
    func showRecovery() {
        showVC(R.storyboard.login.recoveryViewController())
    }
    
    func showMain(_ animated: Bool = true) {
        
    }
    
    func showProject(_ project: Project, delegate: ProjectControllerDelegate? = nil) {
        
    }
    
    // MARK: - Private Functions -
    
    fileprivate func showVC(_ vc: UIViewController?, animated: Bool = true) {
        guard let vc = vc else { return }
        
        if animated {
            controller.show(vc, sender: controller)
        } else {
            controller.navigationController?.viewControllers.append(vc)
        }
    }
}
