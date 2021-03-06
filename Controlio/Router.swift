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
    
    func showLogin(email: String? = nil) {
        let vc = R.storyboard.login.loginViewController()
        vc?.email = email
        show(vc: vc)
    }
    
    func showRecovery(email: String? = nil, delegate: RecoveryViewControllerDelegate? = nil) {
        let vc = R.storyboard.login.recoveryViewController()
        vc?.email = email
        vc?.delegate = delegate
        show(vc: vc)
    }
    
    func showRecovery() {
        show(vc: R.storyboard.login.recoveryViewController())
    }
    
    func showMain(animated: Bool = true) {
        show(vc: MainTabBarController(), animated: animated)
    }
    
    func showClients(with project: Project, type: ClientsTableViewControllerType = .clients) {
        let vc = R.storyboard.main.clientsTableViewController()
        vc?.type = type
        vc?.project = project
        show(vc: vc)
    }
    
    func show(project: Project, delegate: ProjectControllerDelegate? = nil) {
        show(vc: ProjectController(with: project, delegate: delegate))
    }
    
    func showEdit(of project: Project) {
        let vc = R.storyboard.main.editProjectController()
        vc?.project = project
        show(vc: vc)
    }
    
    func showInfo(for project: Project) {
        show(vc: ProjectInfoController(with: project))
    }
    
    func show(user: User) {
        let vc = R.storyboard.main.userViewController()
        vc?.user = user
        show(vc: vc)
    }
    
    func presentChangePassword(with token: String, type: ChangePasswordViewControllerType) {
        let vc = R.storyboard.login.changePasswordViewController()

        vc?.parentVC = controller
        vc?.type = type
        vc?.token = token
        
        present(vc: vc?.snackbarred())
    }
  
    func showEdit(user: User) {
        let vc = R.storyboard.main.editProfileViewController()
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
    
    fileprivate func present(vc: UIViewController?) {
        guard let vc = vc else { return }
        
        controller.present(vc, animated: true, completion: nil)
    }
}

fileprivate extension UIViewController {
    func snackbarred() -> AppSnackbarController {
        return AppSnackbarController(rootViewController: self)
    }
}
