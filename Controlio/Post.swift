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
    var date: Date!
    var manager: User!
    var attachments: [URL]!
}
