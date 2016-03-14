//
//  StartViewController.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 09/03/16.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit
import SnapKit

class StartViewController: UIViewController, UIScrollViewDelegate {
    
    // MARK: - Outlets -
    
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var pageControl: UIPageControl!
    
    // MARK: - Private Variables -
    
    private var labelsText = [
        "Enjoy Controlio!",
        "Track your orders like you track your parcel with UPS or FedEx",
        "Don't wory: everything is super private ;)"]
    
    // MARK: - View Controller Life Cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPageControl()
        addLabels()
        
        // DEBUG
        Router(self).showMain()
    }
    
    // MARK: - UIScrollViewDelegate -
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        pageControl.currentPage = Int(scrollView.contentOffset.x / scrollView.frame.width)
    }
    
    // MARK: - Actions -
    
    @IBAction private func signupTouched(sender: AnyObject) {
        
        Router(self).showSignUp()
    }
    
    @IBAction private func loginTouched(sender: AnyObject) {
        Router(self).showLogIn()
    }
    
    @IBAction private func demoTouched(sender: UIButton) {
        let alert = UIAlertController(title: "What language do you speak?", message: nil, preferredStyle: .ActionSheet)
        alert.addPopoverSourceView(sender)
        alert.addCancelButton()
        for demoAccountLanguage in DemoAccountLanguage.allCases {
            alert.addDefaultAction(demoAccountLanguage.string) {
                self.loginDemo(demoAccountLanguage)
            }
        }
        presentViewController(alert, animated: true) {}
    }
    
    // MARK: - Private Functions -
    
    private func setupPageControl() {
        pageControl.currentPage = 0
        pageControl.numberOfPages = labelsText.count
    }
    
    private func addLabels() {
        var previousLabel: UILabel?
        for text in labelsText {
            let label = UILabel()
            label.textAlignment = NSTextAlignment.Center
            label.text = text
            label.numberOfLines = 0
            label.textColor = UIColor.whiteColor()
            scrollView.addSubview(label)
            
            label.snp_makeConstraints{ make in
                make.width.equalTo(self.scrollView).inset(UIEdgeInsetsMake(0, 4, 0, 4))
                make.centerY.equalTo(self.scrollView)
                if previousLabel != nil {
                    make.left.equalTo(previousLabel!.snp_right).offset(8)
                } else {
                    make.left.equalTo(self.scrollView).offset(4)
                }
                if text == labelsText.last {
                    make.right.equalTo(self.scrollView).inset(4)
                }
            }
            previousLabel = label
        }
    }
    
    private func checkScrollViewOffset() {
        scrollView.contentOffset = CGPointMake(scrollView.frame.width * CGFloat(pageControl.currentPage), 0)
    }
    
    private func loginDemo(type: DemoAccountLanguage) {
        switch type {
        case .English:
            print("Login English")
        case .Russian:
            print("Login Russian")
        }
    }
    
    // MARK: - Rotation -
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        coordinator.animateAlongsideTransition({ context in self.checkScrollViewOffset() }) { context in }
    }
}
