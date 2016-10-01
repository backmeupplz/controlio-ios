//
//  DemoAccountLanguage.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 09/03/16.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit

enum DemoAccountLanguage: String {
    case english = "English"
    case russian = "Russian"
    
    static var allCases: [DemoAccountLanguage] {
        get {
            return [.english, .russian]
        }
    }
}
