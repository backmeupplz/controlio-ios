//
//  Server.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 29/05/16.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON3
import CLTokenInputView

class Server: NSObject {
    
    // MARK: - Properties -
    
    class var currentUser: User? {
        set {
            if let newValue = newValue {
                let data = NSKeyedArchiver.archivedData(withRootObject: newValue)
                UserDefaults.set(data, key: "currentUser")
            } else {
                UserDefaults.set(nil, key: "currentUser")
            }
        }
        get {
            let data = UserDefaults.get("currentUser") as? Data
            if let data = data {
                return NSKeyedUnarchiver.unarchiveObject(with: data) as? User
            } else {
                return nil
            }
        }
    }
    
    // MARK: - Public functions -
    
    class func isLoggedIn() -> Bool {
        return currentUser?.token != nil
    }
    
    // MARK: - Login -
    
    class func signup(email: String, password: String, completion:@escaping (NSError?)->()) {
        let parameters = [
            "email": email,
            "password": password
        ]
        
        request(urlAddition: "users/signUp", method: .post, parameters: parameters, needsToken: false)
        { json, error in
            if let error = error {
                completion(error)
            } else {
                saveUser(json!)
                completion(nil)
            }
        }
    }
    
    class func login(_ email: String, password: String, completion:@escaping (NSError?)->()) {
        let parameters = [
            "email": email,
            "password": password
        ]
        request(urlAddition: "users/login", method: .post, parameters: parameters, needsToken: false)
        { json, error in
            if let error = error {
                completion(error)
            } else {
                saveUser(json!)
                completion(nil)
            }
        }
    }
    
    // MARK: - Profile -
    
    class func getProfile(completion:@escaping (NSError?, User?)->()) {
        request(urlAddition: "users/profile", method: .get, needsToken: true)
        { json, error in
            if let error = error {
                completion(error, nil)
            } else {
                completion(nil, User(json: json!))
            }
        }
    }
    
    class func editProfile(name: String?, phone: String?, profileImage: String?, completion: @escaping (NSError?)->()) {
        var parameters = [String:String]()
        if let name = name {
            parameters["name"] = name
        }
        if let phone = phone {
            parameters["phone"] = phone
        }
        if let profileImage = profileImage {
            parameters["photo"] = profileImage
        }
        request(urlAddition: "users/profile", method: .post, parameters: parameters, needsToken: true)
        { json, error in
            if let error = error {
                completion(error)
            } else {
                saveUser(json!)
                completion(nil)
            }
        }
    }
    
    // MARK: - Managers -
    
    class func getManagers(completion:@escaping (NSError?, [User]?)->()) {
        request(urlAddition: "users/managers", method: .get, needsToken: true)
        { json, error in
            completion(error, User.map(json: json))
        }
    }
    
    class func addManager(email: String, completion:@escaping (NSError?)->()) {
        let parameters = [
            "email": email
        ]
        request(urlAddition: "users/manager", method: .post, parameters: parameters, needsToken: true)
        { json, error in
            completion(error)
        }
    }
    
    class func removeManager(user: User, completion:@escaping (NSError?)->()) {
        let parameters = [
            "id": user.id!
        ]
        request(urlAddition: "users/manager", method: .delete, parameters: parameters, needsToken: true)
        { json, error in
            completion(error)
        }
    }
    
    // MARK: - Projects -
    
    class func addProject(image: String, title: String, initialStatus: String, clients: [CLToken], description: String, manager: User, completion:@escaping (NSError?)->()) {
        let parameters: [String: Any] = [
            "image": image,
            "title": title,
            "status": initialStatus,
            "description": description,
            "manager": manager.id,
            "clients": clients.map { $0.displayText }
        ]
        
        request(urlAddition: "projects", method: .post, parameters: parameters, needsToken: true)
        { json, error in
            completion(error)
        }
    }
    
    class func getProjects(skip: Int = 0, limit: Int = 20, completion:@escaping (NSError?, [Project]?)->()) {
        let parameters = [
            "skip": skip,
            "limit": limit
        ]
        
        request(urlAddition: "projects", method: .get, parameters: parameters, needsToken: true)
        { json, error in
            completion(error, Project.map(json: json))
        }
    }
    
    class func changeStatus(projectId: String, status: String, completion:@escaping (NSError?)->()) {
        let parameters = [
            "projectid": projectId,
            "status": status
        ]
        
        request(urlAddition: "projects/status", method: .post, parameters: parameters, needsToken: true)
        { json, error in
            completion(error)
        }
    }
    
    class func changeClients(projectId: String, clientEmails: [String], completion:@escaping (NSError?)->()) {
        let parameters: [String: Any] = [
            "projectid": projectId,
            "clients": clientEmails
        ]
        
        request(urlAddition: "projects/clients", method: .post, parameters: parameters, needsToken: true)
        { json, error in
            completion(error)
        }
    }
    
    class func editProject(project: Project, title: String, description: String, image: String, completion: @escaping (NSError?)->()) {
        let parameters: [String: String] = [
            "projectid": project.id,
            "title": title,
            "description": description,
            "image": image
        ]
        
        request(urlAddition: "projects", method: .put, parameters: parameters, needsToken: true)
        { json, error in
            completion(error)
        }
    }
    
    // MARK: - Posts -
    
    class func addPost(projectId: String, text: String, attachmentKeys: [String], completion:@escaping (NSError?)->()) {
        let parameters: [String: Any] = [
            "projectid": projectId,
            "text": text,
            "attachments": attachmentKeys
        ]
        
        request(urlAddition: "posts", method: .post, parameters: parameters, needsToken: true)
        { json, error in
            completion(error)
        }
    }
    
    class func getPosts(project: Project, skip: Int = 0, limit: Int = 20, completion:@escaping (NSError?, [Post]?)->()) {
        let parameters: [String: Any] = [
            "projectid": project.id,
            "skip": skip,
            "limit": limit
        ]
        
        request(urlAddition: "posts", method: .get, parameters: parameters, needsToken: true)
        { json, error in
            completion(error, Post.map(json: json, manager: project.manager))
        }
    }
    
    class func editPost(post: Post, text: String, attachments: [String], completion: @escaping (NSError?)->()) {
        let parameters: [String: Any] = [
            "postid": post.id,
            "text": text,
            "attachments": attachments
        ]
        
        request(urlAddition: "posts", method: .put, parameters: parameters, needsToken: true)
        { json, error in
            completion(error)
        }
    }
    
    // MARK: - Private functions -
    
    fileprivate class func request(urlAddition: String, method: HTTPMethod, parameters: [String:Any]? = nil, needsToken: Bool, completion: @escaping (JSON?, NSError?)->()) {
        Alamofire.request(apiUrl + urlAddition, method: method, parameters: parameters, encoding: method == .get ? URLEncoding.default : JSONEncoding.default, headers: headers(needsToken: needsToken))
            .responseJSON { response in
                if let errorString = response.result.error?.localizedDescription {
                    completion(nil, NSError(domain: errorString, code: 500, userInfo: nil))
                } else if let error = checkForErrors(json: JSON(response.result.value)) {
                    completion(nil, error)
                }else if response.response?.statusCode == 500 {
                    completion(nil, NSError(domain: "Server error", code: 500, userInfo: nil))
                } else {
                    completion(JSON(response.result.value), nil)
                }
        }
    }
    
    fileprivate class func checkForErrors(json: JSON) -> NSError? {
        if let error = json["errors"].array?.first {
            return NSError(domain: error["messages"].array?.first?.string ?? "Something went wrong", code: error["status"].int ?? 500, userInfo: nil)
        } else if let errorName = json["errors"].dictionary?.keys.first {
            return NSError(domain: json["errors"][errorName]["message"].string ?? "Something went wrong", code: 500, userInfo: nil)
        } else if let message = json["message"].string {
            return NSError(domain: message, code: json["status"].int ?? 500, userInfo: nil)
        } else {
            return nil
        }
    }
    
    fileprivate class func saveUser(_ user: JSON) {
        currentUser = User(json: user)
    }
    
    fileprivate class func headers(needsToken: Bool) -> [String:String] {
        return needsToken ?
            ["apiKey": apiKey, "token": currentUser?.token ?? "", "userId": currentUser?.id ?? ""] :
            ["apiKey": apiKey]
    }
}
