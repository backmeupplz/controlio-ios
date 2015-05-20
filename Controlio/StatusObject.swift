//
//  StatusObject.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 19/05/15.
//  Copyright (c) 2015 Borodutch Studio LLC. All rights reserved.
//

import Foundation

enum StatusType {
    case Status
    case StatusWithImage
    case TypeChange
    case Time
    func simpleDescription() -> String {
        switch self {
        case .Status:
            return "Status"
        case .StatusWithImage:
            return "StatusWithImage"
        case .TypeChange:
            return "TypeChange"
        case .Time:
            return "Time"
        }
    }
}

class StatusObject {
    var type: StatusType!
    var text: String!
    var attachements: [NSURL]?
}