//
//  ManagerObject.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 19/05/15.
//  Copyright (c) 2015 Borodutch Studio LLC. All rights reserved.
//

import Foundation
import SwiftyJSON

class ManagerObject {
    var image: NSURL?
    var name: String!
    var telephone: String!
    var email: String!
    var website: String!
    
    class func convertJsonToObject(json: JSON) -> ManagerObject {
        var manager = ManagerObject()
        manager.image = json["image"].URL
        manager.name = json["name"].string
        manager.telephone = json["telephone"].string
        manager.email = json["email"].string
        manager.website = json["website"].string
        return manager
    }
}