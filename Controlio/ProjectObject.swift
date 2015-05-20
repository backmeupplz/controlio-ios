//
//  ProjectObject.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 17/05/15.
//  Copyright (c) 2015 Borodutch Studio LLC. All rights reserved.
//

import Foundation

class ProjectObject {
    var identificator: Int!
    var image: NSURL?
    var title: String!
    var timestamp: Int!
    var timestampString: String! {
        get {
            var date = NSDate(timeIntervalSince1970: NSTimeInterval(timestamp))
            var formatter = NSDateFormatter()
            formatter.dateStyle = NSDateFormatterStyle.LongStyle
            formatter.timeStyle = .MediumStyle
            return formatter.stringFromDate(date)
        }
    }
    var message: String!
    var info: String!
    var status: String!
    
    var manager: ManagerObject!
}