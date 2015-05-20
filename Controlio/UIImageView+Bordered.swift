//
//  UIImageView+Bordered.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 19/05/15.
//  Copyright (c) 2015 Borodutch Studio LLC. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    
    // MARK: - Variables -
    
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
}