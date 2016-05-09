
//
//  CustomizableView.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 13/03/16.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit

class CustomizableView: UIView {

    // MARK: - Variables -
    
    @IBInspectable var cornerRadius: CGFloat = 0
    @IBInspectable var shadowColor: UIColor = UIColor.blackColor()
    @IBInspectable var shadowRadius: CGFloat = 0
    @IBInspectable var shadowOpacity: Float = 0
    @IBInspectable var shadowOffset: CGSize = CGSizeZero
    @IBInspectable var borderWidth: CGFloat = 0
    @IBInspectable var borderColor: UIColor = UIColor.clearColor()
    
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
        layer.shadowColor = shadowColor.CGColor
        layer.shadowOffset = shadowOffset
        layer.shadowRadius = shadowRadius
        layer.shadowOpacity = shadowOpacity
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor.CGColor
    }
    
}
