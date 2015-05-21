//
//  StatusObject.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 19/05/15.
//  Copyright (c) 2015 Borodutch Studio LLC. All rights reserved.
//

import Foundation
import SwiftyJSON

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
    var timestamp: Int!
    var type: StatusType!
    var text: String!
    var attachements: [NSURL]?
    
    class func timeStatus(timestamp: Int) -> StatusObject {
        var status = StatusObject()
        status.type = .Time
        status.timestamp = timestamp
        
        var date = NSDate(timeIntervalSince1970: NSTimeInterval(status.timestamp))
        var formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.LongStyle
        formatter.timeStyle = .NoStyle
        status.text = formatter.stringFromDate(date)
        
        return status
    }
    
    class func convertJsonToObject(json: JSON) -> StatusObject {
        var status = StatusObject()
        
        // Timestamp
        status.timestamp = json["create_date_utc"].int
        
        if (json["text"].string == nil) {
            // Text
            status.text = json["status"].string
            // Type
            status.type = .TypeChange
        } else {
            // Text
            status.text = json["text"].string
            
            if (json["attachments"].array?.count > 0) {
                // Type
                status.type = .StatusWithImage
                
                // Attachments
                var temp = [NSURL]()
                var attachments = json["attachments"].array
                for attach in attachments! {
                    temp.append(attach.URL!)
                }
                status.attachements = temp
            } else {
                // Type
                status.type = .Status
            }
        }

        return status
    }
}

