//
//  GradientView.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 09/03/16.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit
import Material

class GradientView: UIView {
    
    // MARK: - Variables -
    
    @IBInspectable var startColor: Color = Color.controlioViolet
    @IBInspectable var endColor: Color = Color.controlioGradientGreen
    
    @IBInspectable var startPoint: CGPoint = CGPoint(x: 0.0, y: 0.0)
    @IBInspectable var endPoint: CGPoint = CGPoint(x: 1.0, y: 1.0)
    
    // MARK: - Private Variables -
    
    fileprivate var gradient: CAGradientLayer?
    
    // MARK: - View Life Cycle -
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        addGradient()
    }
    
    // MARK: - Private Functions -

    fileprivate func addGradient() {
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
        
        let gradient = CGGradient(colorSpace: colorSpace, colorComponents: components, locations: locations, count: componentCount)
        
        let startPoint = CGPoint(x: bounds.width*self.startPoint.x, y: bounds.height*self.startPoint.y)
        let endPoint = CGPoint(x: bounds.width*self.endPoint.x, y: bounds.height*self.endPoint.y)
        
        let context = UIGraphicsGetCurrentContext()
        context?.drawLinearGradient(gradient!, start: startPoint, end: endPoint, options: CGGradientDrawingOptions(rawValue: 0))
    }
}
