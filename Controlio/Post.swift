//
//  Post.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 08/05/16.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit
import SwiftyJSON

enum PostType: String {
    case post = "post"
    case status = "status"
}


class Post: NSObject {
    
    // MARK: - Variables -
    
    var id: String!
    var type: PostType = .post
    
    var text: String!
    var dateCreated: Date!
    var manager: User!
    var attachments: [String]!
    
    // MARK: - Functions -
    
    class func map(json: JSON?, manager: User? = nil) -> [Post]? {
        guard let json = json else { return nil }
        return json.array!.flatMap { Post(json: $0, manager: manager) }
    }
    
    convenience init?(json: JSON?, manager: User? = nil) {
        guard let json = json, !json.isEmpty, let id = json["_id"].string else { return nil }
        
        self.init()
        
        self.id = id
        type = PostType(rawValue: json["type"].string ?? "post") ?? .post
        
        text = json["text"].string
        dateCreated = json["createdAt"].string!.dateFromISO8601
        self.manager = manager
        attachments = json["attachments"].array!.map { $0.string! }
    }
}
