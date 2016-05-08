//
//  Post.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 08/05/16.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit

enum PostType {
    case Status
    case Post
}

class Post: NSObject {
    
    // MARK: - Variables -
    
    var type: PostType!
    var text: String!
}
