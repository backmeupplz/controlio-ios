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
    case Post
    case PostWithImage
    case RecoveredPost
    case RecoveredPostWithImage
    case MissedPost
    case CompletelyMissedPost
    case Status
    case ReportStart
    case ReportChange
    case ReportEnd
    case Time
    func cellNameExtension() -> String {
        switch self {
            
        case .Post:
            return "Post"
        case .PostWithImage:
            return "PostWithImage"
        case .RecoveredPost:
            return "RecoveredPost"
        case .RecoveredPostWithImage:
            return "RecoveredPostWithImage"
        case .MissedPost:
            return "MissedPost"
        case .CompletelyMissedPost:
            return "CompletelyMissedPost"
        case .Status:
            return "Status"
        case .ReportStart, .ReportChange, .ReportEnd:
            return "Report"
        case Time:
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
        var post = StatusObject()
        post.timestamp = json["create_date_utc"].int
        
        switch json["type"].string! {
            case "message":
                post.text = json["text"].string
                if (json["attachments"].array?.count > 0) {
                    post.type = .PostWithImage
                    var temp = [NSURL]()
                    var attachments = json["attachments"].array
                    for attach in attachments! {
                        temp.append(attach.URL!)
                    }
                    post.attachements = temp
                } else {
                    post.type = .Post
                }
            case "status":
                post.text = json["text"].string
                post.type = .Status
            case "report":
                var type = json["text"]["type"].string!
                switch type {
                    case "new":
                        post.type = .ReportStart
                        post.text = NSLocalizedString("Report period was set to: ", comment: "")
                        var dayString = getDayStrings(json["text"]["days"].array!)
                        var hoursString = json["text"]["time"][0].string!
                        var minutesString = json["text"]["time"][1].string!
                        var utcString = json["text"]["utc"].string!
                        if utcString.toInt() >= 0 {
                            utcString = "+" + utcString
                        }
                        post.text = "\(post.text)\(dayString)\(hoursString):\(minutesString), UTC\(utcString)"
                    

                    case "update":
                        post.type = .ReportChange
                        post.text = NSLocalizedString("Report period was changed to: ", comment: "")
                        var dayString = getDayStrings(json["text"]["days"].array!)
                        var hoursString = json["text"]["time"][0].string!
                        var minutesString = json["text"]["time"][1].string!
                        var utcString = json["text"]["utc"].string!
                        if utcString.toInt() >= 0 {
                            utcString = "+" + utcString
                        }
                        post.text = "\(post.text)\(dayString)\(hoursString):\(minutesString), UTC\(utcString)"
                    case "delete":
                        post.type = .ReportEnd
                        post.text = NSLocalizedString("Report reminder was turned off", comment: "")
                    default:
                        break
                }
            
            case "fail":
                var timestamp = NSDate().timeIntervalSince1970
                post.type = Int(timestamp - (60*60*24*3)) > Int(post.timestamp) ? .CompletelyMissedPost : .MissedPost
            case "message_fail":
                post.text = json["text"].string
                if (json["attachments"].array?.count > 0) {
                    post.type = .RecoveredPostWithImage
                    var temp = [NSURL]()
                    var attachments = json["attachments"].array
                    for attach in attachments! {
                        temp.append(attach.URL!)
                    }
                    post.attachements = temp
                } else {
                    post.type = .RecoveredPost
                }
            default:
                break
        }
        return post
    }
    
    class func getDayStrings(array: [JSON]) -> String {
        var result = ""
        
        for number in array {
            switch number.int! {
            case 0:
                result += NSLocalizedString("Mon", comment: "")
            case 1:
                result += NSLocalizedString("Tue", comment: "")
            case 2:
                result += NSLocalizedString("Wed", comment: "")
            case 3:
                result += NSLocalizedString("Thu", comment: "")
            case 4:
                result += NSLocalizedString("Fri", comment: "")
            case 5:
                result += NSLocalizedString("Sat", comment: "")
            case 6:
                result += NSLocalizedString("Sun", comment: "")
            default:
                break
            }
            result += ", "
        }
        
        return result
    }
}

