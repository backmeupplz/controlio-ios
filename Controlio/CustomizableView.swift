
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
    
//    @IBInspectable var cornerRadius: CGFloat = 0
//    @IBInspectable var shadowColor: UIColor = UIColor.black
//    @IBInspectable var shadowRadius: CGFloat = 0
//    @IBInspectable var shadowOpacity: Float = 0
//    @IBInspectable var shadowOffset: CGSize = CGSize.zero
//    @IBInspectable var borderWidth: CGFloat = 0
//    @IBInspectable var borderColor: UIColor = UIColor.clear
    
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
    
    var once = true
    fileprivate func addShadow() {
        if once {
//            layer.shadowColor = shadowColor.cgColor
//            layer.shadowOffset = shadowOffset
//            layer.shadowRadius = shadowRadius
//            layer.shadowOpacity = shadowOpacity
//            layer.borderWidth = borderWidth
//            layer.borderColor = borderColor.cgColor
//            once = false
        }
    }
    
}
