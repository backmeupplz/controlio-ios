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
    
    var startColor = UIColor.controlioViolet()
    var endColor = UIColor.controlioGreen()
    
    var startPoint = CGPoint(x: 0.0, y: 0.0)
    var endPoint = CGPoint(x: 1.0, y: 1.0)
    
    // MARK: - Private Variables -
    
    private var gradient: CAGradientLayer?
    
    // MARK: - View Life Cycle -
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        addGradient()
    }
    
    // MARK: - Private Functions -

    private func addGradient() {
        gradient?.removeFromSuperlayer()
        
        gradient = CAGradientLayer()
        
        gradient!.colors = [startColor.CGColor, endColor.CGColor]
        gradient!.startPoint = startPoint
        gradient!.endPoint = endPoint
        gradient!.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.size.height)
        
        layer.insertSublayer(gradient!, atIndex: 0)
    }
}
