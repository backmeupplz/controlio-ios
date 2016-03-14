//
//  UISearchBar+CursorTint.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 09/03/16.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit

extension UISearchBar {
    func setCursorTintColor(cursorTint: UIColor) {
        let view = subviews.first!
        let subViewsArray = view.subviews
        
        for subView in subViewsArray {
            if subView.isKindOfClass(UITextField){
                subView.tintColor = cursorTint
            }
        }
    }
}
