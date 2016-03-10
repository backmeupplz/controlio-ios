//
//  DemoAccountLanguage.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 09/03/16.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit

enum DemoAccountLanguage: Int {
    case English
    case Russian
    
    var string: String {
        get {
            switch self {
            case .English:
                return "English"
            case .Russian:
                return "Russian"
            }
        }
    }
    static var allCases: [DemoAccountLanguage] {
        get {
            return [.English, .Russian]
        }
    }
}