//
//  ParallaxImageView.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 26/05/15.
//  Copyright (c) 2015 Borodutch Studio LLC. All rights reserved.
//

import Foundation
import UIKit

class ParallaxImageView: UIImageView {
    
    // MARK: View Life Cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        enableParallax()
    }
    
    // MARK: General Methods
    
    func enableParallax() {
        motionEffects?.removeAll(keepCapacity: true)
        
        let verticalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.y",
            type: .TiltAlongVerticalAxis)
        verticalMotionEffect.minimumRelativeValue = -10
        verticalMotionEffect.maximumRelativeValue = 10
        
        // Set horizontal effect
        let horizontalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.x",
            type: .TiltAlongHorizontalAxis)
        horizontalMotionEffect.minimumRelativeValue = -10
        horizontalMotionEffect.maximumRelativeValue = 10
        
        // Create group to combine both
        let group = UIMotionEffectGroup()
        group.motionEffects = [horizontalMotionEffect, verticalMotionEffect]
        
        // Add both effects to your view
        addMotionEffect(group)
    }
}