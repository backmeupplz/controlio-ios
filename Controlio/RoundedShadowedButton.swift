//
//  RoundedShadowedButton.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 09/03/16.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit

class RoundedShadowedButton: UIButton {
    
    // MARK: - Outlets -
    
    @IBOutlet fileprivate var dependantViews: [UIView]?
    
    // MARK: - Variables -
    
    var cornerRadius: CGFloat = 6
    var defaultAlpha = [UIView:CGFloat]()
    override var isHighlighted: Bool {
        didSet {
            if let views = dependantViews {
                for view in views {
                    if isHighlighted {
                        defaultAlpha[view] = view.alpha
//                        view.alpha = view.alpha / 2.0
                    } else {
//                        view.alpha = defaultAlpha[view] ?? 1.0
                    }
                }
            }
        }
    }

    // MARK: - View Life Cycle -
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        roundCorners()
        addShadow()
    }
    
    // MARK: - Private Functions -
    
    fileprivate func roundCorners() {
        layer.cornerRadius = cornerRadius
    }
    
    fileprivate func addShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 3
        layer.shadowOpacity = 0.2
    }
}
