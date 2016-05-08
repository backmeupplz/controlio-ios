//
//  NSDateFormatter+Extensions.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 08/05/16.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit

//let projectDateStringFormatter = NSDateFormatter()

extension NSDateFormatter {
    
    // MARK: - Class Functions -
    
    class func projectDateString(date: NSDate) -> String {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .ShortStyle
        formatter.timeStyle = .ShortStyle
        return formatter.stringFromDate(date)
    }
}