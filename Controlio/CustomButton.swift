//
//  CustomButton.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 19/04/2017.
//  Copyright © 2017 Nikita Kolmogorov. All rights reserved.
//

import UIKit

class CustomButton: UIButton {
    override var isHighlighted: Bool {
        didSet {
            alpha = isHighlighted ? 0.5 : 1
        }
    }
}
