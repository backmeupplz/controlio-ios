//
//  NSAttributedString+Extensions.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 09/04/2017.
//  Copyright © 2017 Nikita Kolmogorov. All rights reserved.
//

import UIKit
import Material

extension NSAttributedString {
    convenience init(string: String, font: UIFont?, color: Color) {
        var attrs: [String: Any] = [
            NSForegroundColorAttributeName: color
        ]
        if let font = font {
            attrs[NSFontAttributeName] = font
        }
        self.init(string: string, attributes: attrs)
    }
}
