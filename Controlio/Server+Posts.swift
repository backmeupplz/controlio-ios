//
//  Server+Posts.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 27/04/2017.
//  Copyright © 2017 Nikita Kolmogorov. All rights reserved.
//

import UIKit
import Alamofire

extension Server {
    class func addPost(to project: Project, text: String, attachmentKeys: [String], completion:@escaping (NSError?, Post?)->()) {
        guard let id = project.id else { return }
        let parameters: Parameters = [
            "projectid": id,
            "text": text,
            "attachments": attachmentKeys,
            "type": "post"
        ]
        if isDemo() {
            completion(NSError(domain: NSLocalizedString("You can't do that in demo account", comment: "Error"), code: 500, userInfo: nil), nil)
            return
        }
        request(urlAddition: "posts", method: .post, parameters: parameters, needsToken: true)
        { json, error in
            completion(error, Post(json: json))
        }
    }
    
    class func getPosts(for project: Project, skip: Int = 0, limit: Int = 20, completion:@escaping (NSError?, [Post]?)->()) {
        guard let id = project.id else { return }
        let parameters: Parameters = [
            "projectid": id,
            "skip": skip,
            "limit": limit
        ]
        
        request(urlAddition: "posts", method: .get, parameters: parameters, needsToken: true)
        { json, error in
            completion(error, Post.map(json: json))
        }
    }
    
    class func editPost(project: Project, post: Post, text: String, attachments: [String], completion: @escaping (NSError?)->()) {
        guard let id = project.id else { return }
        
        let parameters: [String: Any] = [
            "projectid": id,
            "postid": post.id,
            "text": text,
            "attachments": attachments
        ]
        if isDemo() {
            completion(NSError(domain: NSLocalizedString("You can't do that in demo account", comment: "Error"), code: 500, userInfo: nil))
            return
        }
        request(urlAddition: "posts", method: .put, parameters: parameters, needsToken: true)
        { json, error in
            completion(error)
        }
    }
    
    class func deletePost(project: Project, post: Post, completion: @escaping (NSError?)->()) {
        guard let id = project.id else { return }
        
        let parameters: [String: Any] = [
            "projectid": id,
            "postid": post.id
        ]
        if isDemo() {
            completion(NSError(domain: NSLocalizedString("You can't do that in demo account", comment: "Error"), code: 500, userInfo: nil))
            return
        }
        request(urlAddition: "posts", method: .delete, parameters: parameters, needsToken: true)
        { json, error in
            completion(error)
        }
    }
}
