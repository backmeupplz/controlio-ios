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
    
    // MARK: - Debug -
    
    class func testProjects() -> [Project] {
        var result = [Project]()
        
        for _ in 0...20 {
            let project = Project()
            project.title = "Готовим пиццу"
            project.projectDescription = "Мы готовим пиццу, сложно сказать что-то еще"
            project.image = NSURL(string: "https://cdn.evbuc.com/eventlogos/48995724/pizza.jpg")
            project.dateCreated = NSDate()
            
            let manager = Manager()
            manager.name = "Алер Денисов"
            manager.email = "aler@porka.ru"
            manager.phone = "+7 12345677"
            manager.image = NSURL(string: "https://pp.vk.me/c311617/v311617934/6344/4H2t29OBekM.jpg")
            
            let status = Post()
            status.type = .Status
            status.text = "Начали готовить пиццу"
            
            let post = Post()
            post.type = .Post
            post.text = "Ну, что сказать, пиццу засунули в очаг, ждем, пока готовится"
            
            project.manager = manager
            project.lastStatus = status
            project.lastPost = post
            
            result.append(project)
        }
        
        return result
    }
}
