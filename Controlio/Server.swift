//
//  Server.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 29/05/16.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CLTokenInputView
import Stripe

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
    static var pushNotificationsToken: String?
    
    // MARK: - Public functions -
    
    class func isLoggedIn() -> Bool {
        return currentUser?.token != nil
    }
    
    class func isDemo() -> Bool {
        return currentUser?.isDemo ?? false
    } 
    
    // MARK: - Login -
    
    class func signup(email: String, password: String, completion:@escaping (NSError?)->()) {
        var parameters = [
            "email": email,
            "password": password
        ]
        if let pushNotificationsToken = pushNotificationsToken {
            parameters["iosPushToken"] = pushNotificationsToken
        }
        
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
    
    class func login(email: String, password: String, completion:@escaping (NSError?)->()) {
        var parameters = [
            "email": email,
            "password": password
        ]
        if let pushNotificationsToken = pushNotificationsToken {
            parameters["iosPushToken"] = pushNotificationsToken
        }
        
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
    
    class func recoverPassword(_ email: String, completion:@escaping (NSError?)->()) {
        let parameters = [
            "email": email
        ]
        
        request(urlAddition: "users/recoverPassword", method: .post, parameters: parameters, needsToken: false)
        { json, error in
            completion(error)
        }
    }
    
    class func logout() {
        if let pushNotificationsToken = pushNotificationsToken {
            let parameters = ["iosPushToken": pushNotificationsToken]
            
            request(urlAddition: "users/logout", method: .post, parameters: parameters, needsToken: true)
            { json, error in
                if let error = error {
                    print(error)
                }
            }
        }
        currentUser = nil
    }
    
    class func requestMagicLink(_ email: String, completion:@escaping (NSError?)->()) {
        let parameters = [
            "email": email
        ]
        
        request(urlAddition: "users/requestMagicLink", method: .post, parameters: parameters, needsToken: false)
        { json, error in
            completion(error)
        }
    }
    
    class func loginMagicLink(userid: String, token: String, completion:@escaping (NSError?)->()) {
        var parameters = [
            "userid": userid,
            "token": token
        ]
        if let pushNotificationsToken = pushNotificationsToken {
            parameters["iosPushToken"] = pushNotificationsToken
        }
        
        request(urlAddition: "users/loginMagicLink", method: .post, parameters: parameters, needsToken: false)
        { json, error in
            if let error = error {
                completion(error)
            } else {
                if currentUser != nil {
                    completion(NSError(domain: NSLocalizedString("Please logout first", comment: "Error"), code: 500, userInfo: nil))
                } else {
                    saveUser(json!)
                    completion(nil)
                }
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
        if isDemo() {
            completion(NSError(domain: NSLocalizedString("You can't do that in demo account", comment: "Error"), code: 500, userInfo: nil))
            return
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
        if isDemo() {
            completion(NSError(domain: NSLocalizedString("You can't do that in demo account", comment: "Error"), code: 500, userInfo: nil))
            return
        }
        request(urlAddition: "users/manager", method: .post, parameters: parameters, needsToken: true)
        { json, error in
            completion(error)
        }
    }
    
    class func removeManager(user: User, completion:@escaping (NSError?)->()) {
        let parameters = [
            "id": user.id!
        ]
        if isDemo() {
            completion(NSError(domain: NSLocalizedString("You can't do that in demo account", comment: "Error"), code: 500, userInfo: nil))
            return
        }
        request(urlAddition: "users/manager", method: .delete, parameters: parameters, needsToken: true)
        { json, error in
            completion(error)
        }
    }
    
    // MARK: - Projects -
    
    class func add(project: Project, progress:@escaping (Float)->(), completion:@escaping (NSError?)->()) {
        if isDemo() {
            completion(NSError(domain: "You can't do that in demo account", code: 403, userInfo: nil))
            return
        }
        
        var parameters: Parameters = [
            "title": project.title!
        ]
        if project.tempType == .client {
            parameters["type"] = "client"
            parameters["managerEmail"] = project.tempManagerEmail
        } else {
            parameters["type"] = "business"
            parameters["clientEmails"] = project.tempClientEmails
        }
        if let description = project.projectDescription {
            parameters["description"] = description
        }
        if let initialStatus = project.tempInitialStatus {
            parameters["initialStatus"] = initialStatus
        }
        
        if let image = project.tempImage {
            S3.upload(image: image, progress: progress)
            { key, error in
                if let error = error {
                    completion(NSError(domain: error, code: 500, userInfo: nil))
                } else if let key = key {
                    parameters["image"] = key
                    request(urlAddition: "projects", method: .post, parameters: parameters, needsToken: true)
                    { json, error in
                        completion(error)
                    }
                }
            }
        } else {
            request(urlAddition: "projects", method: .post, parameters: parameters, needsToken: true)
            { json, error in
                completion(error)
            }
        }
    }
    
    class func addProject(image: String, title: String, initialStatus: String, clients: [CLToken], description: String, manager: User, completion:@escaping (NSError?)->()) {
        let parameters: [String: Any] = [
            "image": image,
            "title": title,
            "status": initialStatus,
            "description": description,
            "manager": manager.id,
            "clients": clients.map { $0.displayText }
        ]
        
        if isDemo() {
            completion(NSError(domain: NSLocalizedString("You can't do that in demo account", comment: "Error"), code: 500, userInfo: nil))
            return
        }
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
    
    class func getInvitedProjects(completion:@escaping (NSError?, [Project]?)->()) {
        request(urlAddition: "projects/invites", method: .get, needsToken: true)
        { json, error in
            completion(error, Project.map(json: json)?.filter { $0.createdType != nil })
        }
    }
    
    class func invite(approve: Bool, project: Project, completion: @escaping (NSError?)->()) {
        let parameters: Parameters = [
            "projectId": project.id,
            "accept": approve ? 1 : 0
        ]
        
        request(urlAddition: "projects/invites", method: .post, parameters: parameters, needsToken: true)
        { json, error in
            completion(error)
        }
    }
    
    class func changeStatus(projectId: String, status: String, completion:@escaping (NSError?)->()) {
//        let parameters = [
//            "projectid": projectId,
//            "text": status,
//            "type": "status"
//        ]
//        if isDemo() {
//            completion(NSError(domain: NSLocalizedString("You can't do that in demo account", comment: "Error"), code: 500, userInfo: nil))
//            return
//        }
//        request(urlAddition: "posts", method: .post, parameters: parameters, needsToken: true)
//        { json, error in
//            completion(error)
//        }
    }
    
    class func changeClients(projectId: String, clientEmails: [String], completion:@escaping (NSError?)->()) {
//        let parameters: [String: Any] = [
//            "projectid": projectId,
//            "clients": clientEmails
//        ]
//        if isDemo() {
//            completion(NSError(domain: NSLocalizedString("You can't do that in demo account", comment: "Error"), code: 500, userInfo: nil))
//            return
//        }
//        request(urlAddition: "projects/clients", method: .post, parameters: parameters, needsToken: true)
//        { json, error in
//            completion(error)
//        }
    }
    
    class func editProject(project: Project, title: String, description: String, image: String, completion: @escaping (NSError?)->()) {
//        let parameters: [String: String] = [
//            "projectid": project.id,
//            "title": title,
//            "description": description,
//            "image": image
//        ]
//        if isDemo() {
//            completion(NSError(domain: NSLocalizedString("You can't do that in demo account", comment: "Error"), code: 500, userInfo: nil))
//            return
//        }
//        request(urlAddition: "projects", method: .put, parameters: parameters, needsToken: true)
//        { json, error in
//            completion(error)
//        }
    }
    
    class func archive(project: Project, archive: Bool, completion: @escaping (NSError?)->()) {
//        let parameters: [String: String] = [
//            "projectid": project.id
//        ]
//        if isDemo() {
//            completion(NSError(domain: NSLocalizedString("You can't do that in demo account", comment: "Error"), code: 500, userInfo: nil))
//            return
//        }
//        
//        let urlAddition = archive ? "projects/archive" : "projects/unarchive"
//        request(urlAddition: urlAddition, method: .post, parameters: parameters, needsToken: true)
//        { json, error in
//            completion(error)
//        }
    }
    
    class func delete(project: Project, completion: @escaping (NSError?)->()) {
//        let parameters: [String: String] = [
//            "projectid": project.id
//        ]
//        if isDemo() {
//            completion(NSError(domain: NSLocalizedString("You can't do that in demo account", comment: "Error"), code: 500, userInfo: nil))
//            return
//        }
//        request(urlAddition: "projects", method: .delete, parameters: parameters, needsToken: true)
//        { json, error in
//            completion(error)
//        }
    }
    
    // MARK: - Posts -
    
    class func addPost(projectId: String, text: String, attachmentKeys: [String], completion:@escaping (NSError?)->()) {
        let parameters: [String: Any] = [
            "projectid": projectId,
            "text": text,
            "attachments": attachmentKeys
        ]
        if isDemo() {
            completion(NSError(domain: NSLocalizedString("You can't do that in demo account", comment: "Error"), code: 500, userInfo: nil))
            return
        }
        request(urlAddition: "posts", method: .post, parameters: parameters, needsToken: true)
        { json, error in
            completion(error)
        }
    }
    
    class func getPosts(project: Project, skip: Int = 0, limit: Int = 20, completion:@escaping (NSError?, [Post]?)->()) {
//        let parameters: [String: Any] = [
//            "projectid": project.id,
//            "skip": skip,
//            "limit": limit
//        ]
//        
//        request(urlAddition: "posts", method: .get, parameters: parameters, needsToken: true)
//        { json, error in
//            completion(error, Post.map(json: json, manager: project.manager))
//        }
    }
    
    class func editPost(post: Post, text: String, attachments: [String], completion: @escaping (NSError?)->()) {
        let parameters: [String: Any] = [
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
    
    class func deletePost(post: Post, completion: @escaping (NSError?)->()) {
        let parameters: [String: Any] = [
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
    
    // MARK: - Payments -
    
    class func stripeGetCustomer(completion: @escaping (DefaultDataResponse?, NSError?)->()) {
        let parameters: [String: Any] = [
            "customerid": currentUser?.stripeId ?? ""
        ]
        requestData(urlAddition: "payments/customer", method: .get, parameters: parameters, needsToken: true)
        { response, error in
            completion(response, error)
        }
    }
    
    class func stripeCustomerAttach(sourceId: String, completion: @escaping (NSError?)->()) {
        let parameters: [String: Any] = [
            "source": sourceId,
            "customerid": currentUser?.stripeId ?? ""
        ]
        request(urlAddition: "payments/customer/sources", method: .post, parameters: parameters, needsToken: true)
        { json, error in
            completion(error)
        }
    }
    
    class func stripeCustomerSelect(defaultSourceId: String, completion: @escaping (NSError?)->()) {
        let parameters: [String: Any] = [
            "source": defaultSourceId,
            "customerid": currentUser?.stripeId ?? ""
        ]
        request(urlAddition: "payments/customer/default_source", method: .post, parameters: parameters, needsToken: true)
        { json, error in
            completion(error)
        }
    }
    
    class func stripeCustomerChoose(plan: Plan, completion: @escaping (NSError?)->()) {
        let parameters: [String: Any] = [
            "planid": plan.rawValue,
        ]
        request(urlAddition: "payments/customer/subscription", method: .post, parameters: parameters, needsToken: true)
        { json, error in
            if let error = error {
                completion(error)
            } else {
                saveUser(json!)
                completion(nil)
            }
        }
    }
    
    class func stripeRedeemCoupon(coupon: String, completion: @escaping (NSError?)->()) {
        let parameters: [String: Any] = [
            "coupon": coupon,
        ]
        request(urlAddition: "payments/customer/coupon", method: .post, parameters: parameters, needsToken: true)
        { json, error in
            completion(error)
        }
    }
    
    // MARK: - Features -
    
    class func features(completion: @escaping (JSON?, NSError?)->()) {
        request(urlAddition: "feature_list", method: .get, needsToken: false)
        { json, error in
            completion(json, error)
        }
    }
    
    // MARK: - Functions -
    
    class func saveUser(_ user: JSON) {
        currentUser = User(json: user)
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
                    completion(nil, NSError(domain: NSLocalizedString("Server error", comment: "Error"), code: 500, userInfo: nil))
                } else {
                    completion(JSON(response.result.value), nil)
                }
        }
    }
    
    fileprivate class func requestData(urlAddition: String, method: HTTPMethod, parameters: [String:Any]? = nil, needsToken: Bool, completion: @escaping (DefaultDataResponse?, NSError?)->()) {
        Alamofire.request("https://api.controlio.co/" + urlAddition, method: method, parameters: parameters, encoding: method == .get ? URLEncoding.default : JSONEncoding.default, headers: headers(needsToken: needsToken))
            .response { response in
                if let errorString = response.error?.localizedDescription {
                    completion(nil, NSError(domain: errorString, code: 500, userInfo: nil))
                } else if let error = self.checkForErrors(json: JSON(response.data)) {
                    completion(nil, error)
                } else if response.response?.statusCode == 500 {
                    completion(nil, NSError(domain: NSLocalizedString("Server error", comment: "Error"), code: 500, userInfo: nil))
                } else {
                    completion(response, nil)
                }
        }
    }
    
    fileprivate class func checkForErrors(json: JSON) -> NSError? {
        if let error = json["errors"].array?.first {
            return NSError(domain: error["messages"].array?.first?.string ?? NSLocalizedString("Something went wrong", comment: "Error"), code: error["status"].int ?? 500, userInfo: nil)
        } else if let errorName = json["errors"].dictionary?.keys.first {
            return NSError(domain: json["errors"][errorName]["message"].string ?? NSLocalizedString("Something went wrong", comment: "Error"), code: 500, userInfo: nil)
        } else if let message = json["message"].string {
            return NSError(domain: message, code: json["status"].int ?? 500, userInfo: nil)
        } else {
            return nil
        }
    }
    
    fileprivate class func headers(needsToken: Bool) -> [String:String] {
        return needsToken ?
            ["apiKey": apiKey, "token": currentUser?.token ?? "", "userId": currentUser?.id ?? ""] :
            ["apiKey": apiKey]
    }
}
