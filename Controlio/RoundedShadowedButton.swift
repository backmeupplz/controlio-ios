//
//  RoundedShadowedButton.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 09/03/16.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit

class RoundedShadowedButton: UIButton {
    
    // MARK: - Variables -
    
    var cornerRadius: CGFloat = 6

    // MARK: - View Life Cycle -
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        roundCorners()
        addShadow()
    }
    
    // MARK: - Private Functions -
    
    private func roundCorners() {
        layer.cornerRadius = cornerRadius
    }
    
    private func addShadow() {
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOffset = CGSizeMake(0, 2)
        layer.shadowRadius = 3
        layer.shadowOpacity = 0.2
    }
}
