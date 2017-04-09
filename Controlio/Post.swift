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
    var author: User!
    var attachments: [String]!
    var isEdited = false
    
    // MARK: - Functions -
    
    func countAttachments() -> Int {
        return self.attachments.count
    }
    
    class func map(json: JSON?) -> [Post]? {
        guard let array = json?.array else { return nil }
        return array.flatMap { Post(json: $0) }
    }

    convenience init?(json: JSON?) {
        guard let json = json, !json.isEmpty, let id = json["_id"].string else { return nil }
        
        self.init()
        
        self.id = id
        type = PostType(rawValue: json["type"].string ?? "post") ?? .post
        
        text = json["text"].string
        dateCreated = json["createdAt"].string!.dateFromISO8601
        author = User(json: json["author"])
        attachments = json["attachments"].array!.map { $0.string! }
        isEdited = json["isEdited"].bool ?? false
    }
}
