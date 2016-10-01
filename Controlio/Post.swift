//
//  Post.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 08/05/16.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit
import SwiftyJSON3

class Post: NSObject {
    
    // MARK: - Variables -
    
    var text: String!
    var date: Date!
    var manager: User!
    var attachments: [URL]!
    
    // MARK: - Functions -
    
    class func map(json: JSON) -> [Post] {
        return json.array!.flatMap { Post(json: $0) }
    }
    
    convenience init?(json: JSON?) {
        guard json != nil else { return nil }
        
        self.init()
    }
}
