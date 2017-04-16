//
//  SnackbarController+Controlio.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 07/01/2017.
//  Copyright © 2017 Nikita Kolmogorov. All rights reserved.
//

import UIKit
import Material

class AppSnackbarController: SnackbarController {
    
    // MARK: - Variables -
    
    fileprivate var hideButton: FlatButton!
    fileprivate var hideAnimation: MotionDelayCancelBlock?
    
    // MARK: - View Life Cycle -
    
    open override func prepare() {
        super.prepare()
        
        setupHideButton()
    }
    
    // MARK: - Private functions -
    
    fileprivate func setupHideButton() {
        hideButton = FlatButton(title: NSLocalizedString("Hide", comment: "snackbar button"), titleColor: Color.white)
        hideButton.pulseAnimation = .backing
        hideButton.titleLabel?.font = snackbarController?.snackbar.textLabel.font
        hideButton.addTarget(self, action: #selector(AppSnackbarController.hideSnackbar), for: .touchUpInside)
        snackbar.rightViews = [hideButton]
    }
    
    // MARK: - Actions -
    
    func hideSnackbar() {
        _ = animate(snackbar: .hidden, delay: 0)
    }
    
    // MARK: - General functions -
    
    override func show(error: String) {
        snackbar.text = error
        snackbar.backgroundColor = Color.red.darken2
        
        hideAnimation?(true)
        _ = animate(snackbar: .visible, delay: 0)
        hideAnimation = animate(snackbar: .hidden, delay: 4)
    }
    
    override func show(text: String) {
        snackbar.text = text
        snackbar.backgroundColor = Color.teal.base
        
        hideAnimation?(true)
        _ = animate(snackbar: .visible, delay: 0)
        hideAnimation = animate(snackbar: .hidden, delay: 4)
    }
    
    // MARK: - Status Bar -
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension SnackbarController {
    func show(error: String) {
        snackbar.text = error
        snackbar.backgroundColor = Color.red.darken2
        
        _ = animate(snackbar: .visible, delay: 0)
        _ = animate(snackbar: .hidden, delay: 4)
    }
    
    func show(text: String) {
        snackbar.text = text
        snackbar.backgroundColor = Color.teal.base
        
        _ = animate(snackbar: .visible, delay: 0)
        _ = animate(snackbar: .hidden, delay: 4)
    }
}
