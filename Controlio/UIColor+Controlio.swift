//
//  UIColor+Controlio.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 09/03/16.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit
import Material

extension UIColor {
    
    // MARK: - General Functions -
    
    static var controlioViolet: Color {
        return Color(wholeRed: 176, green: 164, blue: 253, alpha: 1)
    }
    static var controlioGreen: Color {
        return Color(wholeRed: 3, green: 195, blue: 134, alpha: 1)
    }
    static var controlioGradientGreen: Color {
        return Color(wholeRed: 72, green: 207, blue: 170, alpha: 1)
    }
    static var controlioTableBackground: Color {
        return Color(wholeRed: 244, green: 246, blue: 249, alpha: 1)
    }
    static var controlioGrayText: Color {
        return Color(wholeRed: 88, green: 93, blue: 108, alpha: 0.5)
    }
    static var controlioBlackText: Color {
        return Color(wholeRed: 88, green: 93, blue: 108, alpha: 1)
    }
    
    // MARK: - Private functions -
    
    fileprivate convenience init(wholeRed: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        self.init(red: wholeRed/255.0, green: green/255.0, blue: blue/255.0, alpha: alpha)
    }
}
