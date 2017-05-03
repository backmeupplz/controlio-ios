//
//  ProgressView.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 02/05/2017.
//  Copyright © 2017 Nikita Kolmogorov. All rights reserved.
//

import UIKit

protocol ProgressViewDelegate: class {
    func progressViewChanged(value: Int)
}

class ProgressView: UIView {
    
    // MARK: - Variables -
    
    var delegate: ProgressViewDelegate?
    var canEdit = false
    var progress: Int = 0 {
        didSet {
            configure()
        }
    }
    
    // MARK: - Outlets -
    
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet fileprivate weak var plusButton: UIButton!
    @IBOutlet fileprivate weak var minusButton: UIButton!
    @IBOutlet fileprivate weak var percentLabel: UILabel!
    
    @IBOutlet fileprivate weak var progressViewLeading: NSLayoutConstraint!
    @IBOutlet fileprivate weak var progressViewTrailing: NSLayoutConstraint!
    
    // MARK: - Actions -
    
    fileprivate var minusTimer: Timer?
    
    @IBAction func minusDown(_ sender: UIButton) {
        decrementProgress()
        minusTimer = Timer.scheduledTimer(timeInterval: 0.1,
                           target: self,
                           selector: #selector(ProgressView.decrementProgress),
                           userInfo: nil,
                           repeats: true)
    }
    
    @IBAction func minusUp(_ sender: UIButton) {
        minusTimer?.invalidate()
        delegate?.progressViewChanged(value: progress)
    }
    
    fileprivate var plusTimer: Timer?
    
    @IBAction func plusDown(_ sender: UIButton) {
        incrementProgress()
        plusTimer = Timer.scheduledTimer(timeInterval: 0.1,
                           target: self,
                           selector: #selector(ProgressView.incrementProgress),
                           userInfo: nil,
                           repeats: true)
    }
    
    @IBAction func plusUp(_ sender: UIButton) {
        plusTimer?.invalidate()
        delegate?.progressViewChanged(value: progress)
    }
    
    // MARK: - Private functions -
    
    fileprivate func configure() {
        progressView.progress = Float(progress)/100.0
        percentLabel.text = "\(progress)%"
        minusButton.isHidden = !canEdit
        plusButton.isHidden = !canEdit
        progressViewLeading.priority = canEdit ? 500 : 800
        progressViewTrailing.priority = canEdit ? 500 : 800
    }
    
    @objc fileprivate func incrementProgress() {
        if progress < 100 {
            progress += 1
        }
    }
    
    @objc fileprivate func decrementProgress() {
        if progress > 0 {
            progress -= 1
        }
    }
}
