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
    var image: URL!
    var dateCreated: Date!
    var status: String!
    
    var manager: User!
    
    var lastPost: Post?
    var posts: [Post]!
    
    var canEdit: Bool = false
}
