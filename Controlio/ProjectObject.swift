//
//  ProjectObject.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 17/05/15.
//  Copyright (c) 2015 Borodutch Studio LLC. All rights reserved.
//

import Foundation
import SwiftyJSON

class ProjectObject {
    var identificator: Int!
    var image: NSURL?
    var title: String!
    var timestamp: Int!
    var timestampString: String! {
        get {
            let date = NSDate(timeIntervalSince1970: NSTimeInterval(timestamp))
            let formatter = NSDateFormatter()
            formatter.dateStyle = NSDateFormatterStyle.LongStyle
            formatter.timeStyle = .MediumStyle
            return formatter.stringFromDate(date)
        }
    }
    var message: String!
    var info: String!
    var status: String!
    
    var manager: ManagerObject!
    
    var adminRights: Bool!
    
    class func convertJsonToObject(json: JSON) -> ProjectObject {
        let obj = ProjectObject()
        
        obj.identificator = json["id"].int
        obj.image = json["thumbnail"].URL
        obj.title = json["title"].string
        obj.timestamp = json["create_date_utc"].int
        obj.message = json["last_post"]["text"].string
        obj.info = json["description"].string
        obj.status = json["status"].string
        obj.adminRights = false
        
        obj.manager = ManagerObject.convertJsonToObject(json["manager"])
        
        return obj
    }
}