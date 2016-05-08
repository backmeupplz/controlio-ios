//
//  NSIndexPath+RowSection.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 07/05/16.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit

extension NSIndexPath {
    
    // MARK: - Class Functions -
    
    convenience init(_ row: Int = 0, section: Int = 0) {
        self.init(forRow:row, inSection: section)
    }
}
