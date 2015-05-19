//
//  RoundImageView.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 18/05/15.
//  Copyright (c) 2015 Borodutch Studio LLC. All rights reserved.
//

import Foundation
import UIKit

class RoundImageView: UIImageView {
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.masksToBounds = true
        self.layer.cornerRadius = frame.size.width/2
    }
}