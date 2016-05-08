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
    
    // MARK: - Private Class Functions -
    
    private class func startVC() -> UIViewController {
        return loginStoryboard().instantiateViewControllerWithIdentifier(String(StartViewController))
    }
    
    private class func logInVC() -> UIViewController {
        return loginStoryboard().instantiateViewControllerWithIdentifier(String(LogInViewController))
    }
    
    private class func signUpVC() -> UIViewController {
        return loginStoryboard().instantiateViewControllerWithIdentifier(String(SignUpViewController))
    }
    
    private class func recoveryVC() -> UIViewController {
        return loginStoryboard().instantiateViewControllerWithIdentifier(String(RecoveryViewController))
    }
    
    private class func mainTBC() -> UIViewController {
        return mainStoryboard().instantiateViewControllerWithIdentifier(String(MainController))
    }
    
    private class func projectVC(project: Project) -> UIViewController {
        let vc =  mainStoryboard().instantiateViewControllerWithIdentifier(String(ProjectController)) as! ProjectController
        vc.project = project
        return vc
    }
    
    // MARK: - Public Functions -
    
    func showStart() {
        showVC(Router.startVC())
    }
    
    func showSignUp() {
        showVC(Router.signUpVC())
    }
    
    func showLogIn() {
        showVC(Router.logInVC())
    }
    
    func showRecovery() {
        showVC(Router.recoveryVC())
    }
    
    func showMain(animated: Bool = true) {
        showVC(Router.mainTBC(), animated: animated)
    }
    
    func showProject(project: Project) {
        showVC(Router.projectVC(project))
    }
    
    // MARK: - Private Functions -
    
    private func showVC(vc: UIViewController, animated: Bool = true) {
        if animated {
            controller.showViewController(vc, sender: controller)
        } else {
            controller.navigationController?.viewControllers.append(vc)
        }
    }
    
    private class func loginStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Login", bundle: nil)
    }
    
    private class func mainStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Main", bundle: nil)
    }
}
