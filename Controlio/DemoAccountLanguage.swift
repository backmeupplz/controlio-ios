//
//  DemoAccountLanguage.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 09/03/16.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit

enum DemoAccountLanguage: Int {
    case english
    case russian
    
    var string: String {
        get {
            switch self {
            case .english:
                return "English"
            case .russian:
                return "Russian"
            }
        }
    }
    static var allCases: [DemoAccountLanguage] {
        get {
            return [.english, .russian]
        }
    }
}
