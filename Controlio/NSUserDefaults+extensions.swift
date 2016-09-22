//
//  NSUserDefaults+extensions.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 29/05/16.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit

extension UserDefaults {
    
    // MARK: - Class functions -
    
    class func set(_ value: Any?, key: String) {
        UserDefaults.standard.setValue(value, forKey: key)
    }
    
    class func get(_ key: String) -> Any? {
        return UserDefaults.standard.value(forKey: key)
    }
}
