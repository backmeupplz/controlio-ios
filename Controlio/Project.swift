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
    var status: String!
    
    var manager: Manager!
    
    var lastPost: Post?
    var posts: [Post]!
    
    var canEdit: Bool = false
    
    // MARK: - Debug -
    
    class func testProjects() -> [Project] {
        var result = [Project]()
        
        for _ in 0...5 {
            let project = Project()
            project.title = "Готовим пиццу"
            project.projectDescription = "Мы готовим пиццу, сложно сказать что-то еще. Пицца в соусе макарено и полным фаршем с ананасами, анчоусами, грибами, блекджеком и куртизанками."
            project.image = NSURL(string: "https://cdn.evbuc.com/eventlogos/48995724/pizza.jpg")
            project.dateCreated = NSDate()
            project.status = "Начали готовить пиццу"
            
            let manager = Manager()
            manager.name = "Алер Денисов"
            manager.email = "aler@porka.ru"
            manager.phone = "+7 12345677"
            manager.image = NSURL(string: "https://pp.vk.me/c311617/v311617934/6344/4H2t29OBekM.jpg")
            
            let post = Post()
            post.text = "Ну, что сказать, пиццу засунули в очаг, ждем, пока готовится"
            
            var posts = [Post]()
            
            for number in 0...4 {
                let post = Post()
                post.text = "Ну, что сказать, пиццу засунули в очаг, ждем, пока готовится"
                post.date = NSDate().dateByAddingTimeInterval(NSTimeInterval(-number*100))
                post.manager = manager
                post.attachments = [NSURL]()
                if number > 0 {
                    for i in 0...number-1 {
                        let url = NSURL(string: i % 2 == 0 ? "https://i.kinja-img.com/gawker-media/image/upload/wafswectpmbr0zmug9ly.jpg" : "http://desotosff.com/wp-content/uploads/2014/07/roni.jpg")!
                        post.attachments.append(url)
                    }
                }
                posts.append(post)
            }
            
            project.manager = manager
            project.lastPost = post
            project.posts = posts
            
            project.canEdit = true
            
            result.append(project)
        }
        
        return result
    }
}
