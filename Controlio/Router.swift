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
    
    func showClients(with project: Project, type: ClientsTableViewControllerType = .clients) {
        let vc = R.storyboard.main.clientsTableViewController()
        vc?.type = type
        vc?.project = project
        show(vc: vc)
    }
    
    func show(project: Project, delegate: ProjectControllerDelegate? = nil) {
        let vc = R.storyboard.main.projectController()
        vc?.project = project
        show(vc: vc)
    }
    
    func showInfo(for project: Project, delegate: ProjectControllerDelegate? = nil) {
        let vc = R.storyboard.main.projectInfoController()
        vc?.project = project
        show(vc: vc)
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
