//
//  Post.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 08/05/16.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit

class Post: NSObject {
    
    // MARK: - Variables -
    
    var text: String!
    var date: NSDate!
    var manager: Manager!
    var attachments: [NSURL]!
}
