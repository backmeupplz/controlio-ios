//
//  Project.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 08/05/16.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit

class Project: NSObject {
    
    // MARK: - Variables -
    
    var title: String!
    var projectDescription: String!
    var image: NSURL!
    var dateCreated: NSDate!
    
    var manager: Manager!
    
    var lastStatus: Post!
    var lastPost: Post?
    
    var posts: [Post]!
}
