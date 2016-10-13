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
    
    fileprivate class func startVC() -> UIViewController {
        return loginStoryboard().instantiateViewController(withIdentifier: "StartViewController")
    }
    
    fileprivate class func logInVC() -> UIViewController {
        return loginStoryboard().instantiateViewController(withIdentifier: "LogInViewController")
    }
    
    fileprivate class func magicLinkVC() -> UIViewController {
        return loginStoryboard().instantiateViewController(withIdentifier: "MagicLinkViewController")
    }
    
    fileprivate class func signUpVC() -> UIViewController {
        return loginStoryboard().instantiateViewController(withIdentifier: "SignUpViewController")
    }
    
    fileprivate class func recoveryVC() -> UIViewController {
        return loginStoryboard().instantiateViewController(withIdentifier: "RecoveryViewController")
    }
    
    fileprivate class func mainTBC() -> UIViewController {
        return mainStoryboard().instantiateViewController(withIdentifier: "MainController")
    }
    
    fileprivate class func projectVC(_ project: Project, delegate: ProjectControllerDelegate? = nil) -> UIViewController {
        let vc =  mainStoryboard().instantiateViewController(withIdentifier: "ProjectController") as! ProjectController
        vc.project = project
        vc.delegate = delegate
        return vc
    }
    
    // MARK: - Public Functions -
    
    func showStart() {
        showVC(Router.startVC())
    }
    
    func showMagicLink() {
        showVC(Router.magicLinkVC())
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
    
    func showMain(_ animated: Bool = true) {
        showVC(Router.mainTBC(), animated: animated)
    }
    
    func showProject(_ project: Project, delegate: ProjectControllerDelegate? = nil) {
        showVC(Router.projectVC(project, delegate: delegate))
    }
    
    // MARK: - Private Functions -
    
    fileprivate func showVC(_ vc: UIViewController, animated: Bool = true) {
        if animated {
            controller.show(vc, sender: controller)
        } else {
            controller.navigationController?.viewControllers.append(vc)
        }
    }
    
    fileprivate class func loginStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Login", bundle: nil)
    }
    
    fileprivate class func mainStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Main", bundle: nil)
    }
}
