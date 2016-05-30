//
//  NSUserDefaults+extensions.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 29/05/16.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit

extension NSUserDefaults {
    
    // MARK: - Class functions -
    
    class func set(value: AnyObject?, key: String) {
        NSUserDefaults.standardUserDefaults().setValue(value, forKey: key)
    }
    
    class func getString(key: String) -> String? {
        return NSUserDefaults.standardUserDefaults().valueForKey(key) as? String
    }
}