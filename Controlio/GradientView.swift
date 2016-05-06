//
//  GradientView.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 09/03/16.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit

class GradientView: UIView {
    
    // MARK: - Variables -
    
    @IBInspectable var startColor = UIColor.controlioViolet()
    @IBInspectable var endColor = UIColor.controlioGradientGreen()
    
    @IBInspectable var startPoint = CGPoint(x: 0.0, y: 0.0)
    @IBInspectable var endPoint = CGPoint(x: 1.0, y: 1.0)
    
    // MARK: - Private Variables -
    
    private var gradient: CAGradientLayer?
    
    // MARK: - View Life Cycle -
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        addGradient()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
//        addGradient()
    }
    
    // MARK: - Private Functions -

    private func addGradient() {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let componentCount = 2
            
        var fRed: CGFloat = 0
        var fGreen: CGFloat = 0
        var fBlue: CGFloat = 0
        var fAlpha: CGFloat = 0
        
        var sRed: CGFloat = 0
        var sGreen: CGFloat = 0
        var sBlue: CGFloat = 0
        var sAlpha: CGFloat = 0
        
        startColor.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha)
        endColor.getRed(&sRed, green: &sGreen, blue: &sBlue, alpha: &sAlpha)
        
        let components = [
            fRed, fGreen, fBlue, fAlpha,
            sRed, sGreen, sBlue, sAlpha
        ]
        
        let locations : [CGFloat] = [0, 1]
        
        let gradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, componentCount)
        
        let startPoint = CGPoint(x: CGRectGetWidth(bounds)*self.startPoint.x, y: CGRectGetHeight(bounds)*self.startPoint.y)
        let endPoint = CGPoint(x: CGRectGetWidth(bounds)*self.endPoint.x, y: CGRectGetHeight(bounds)*self.endPoint.y)
        
        let context = UIGraphicsGetCurrentContext()
        CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, CGGradientDrawingOptions(rawValue: 0))
    }
}
