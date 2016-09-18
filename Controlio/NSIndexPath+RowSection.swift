//
//  NSIndexPath+RowSection.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 07/05/16.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit

extension IndexPath {
    
    // MARK: - Class Functions -
    
    init(_ row: Int = 0, section: Int = 0) {
        self.init()
        self.row = row
        self.section = section
    }
}
