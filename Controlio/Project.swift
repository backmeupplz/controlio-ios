//
//  Project.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 08/05/16.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit
import SwiftyJSON3

class Project: NSObject {
    
    // MARK: - Variables -
    
    var id: String!
    
    var title: String!
    var projectDescription: String!
    var imageKey: String!
    var dateCreated: Date!
    var status: String!
    
    var manager: User!
    
    var lastPost: Post?
    
    var canEdit: Bool = false
    
    // MARK: - Functions -
    
    class func map(json: JSON?) -> [Project]? {
        guard let json = json else { return nil }
        return json.array!.map { Project(json: $0) }
    }
    
    convenience init(json: JSON) {
        self.init()
        
        id = json["_id"].string!
        
        title = json["title"].string!
        projectDescription = json["description"].string!
        imageKey = json["image"].string!
        dateCreated = json["createdAt"].string!.dateFromISO8601!
        status = json["status"].string!
        
        manager = User(json: json["manager"])
        
        lastPost = Post(json: json["lastPost"])
        
        canEdit = json["canEdit"].bool ?? false
    }
}
