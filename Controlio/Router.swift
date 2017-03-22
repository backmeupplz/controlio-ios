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
    
    func showLogin(_ email: String?, _ state: LoginViewControllerState?) {
        let vc = R.storyboard.login.loginViewController()
        vc?.setEmail(email: email ?? "")
        vc?.state = state ?? .signup
        show(vc: vc)
    }
    
    func showRecovery(_ email: String?) {
        let vc = R.storyboard.login.recoveryViewController()
        vc?.setEmail(email: email ?? "")
        show(vc: vc)
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
    
    func show(project: Project) {
        let vc = R.storyboard.main.projectController()
        vc?.project = project
        show(vc: vc)
    }
    
    func showEdit(of project: Project) {
        let vc = R.storyboard.main.editProjectController()
        vc?.project = project
        show(vc: vc)
    }
    
    func showInfo(for project: Project) {
        let vc = R.storyboard.main.projectInfoController()
        vc?.project = project
        show(vc: vc)
    }
    
    func show(user: User) {
        let vc = R.storyboard.main.userViewController()
        vc?.user = user
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
