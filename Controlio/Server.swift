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

    class func resetPassword(token: String, password: String, completion:@escaping (NSError?)->()) {
        let parameters = [
            "token": token,
            "password": password
        ]

        request(urlAddition: "users/resetPassword", method: .post, parameters: parameters, needsToken: false)
        { json, error in
            completion(error)
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
    
    class func loginMagicLink(token: String, completion:@escaping (NSError?)->()) {
        if currentUser != nil {
            completion(NSError(domain: NSLocalizedString("Please logout first", comment: "Error"), code: 500, userInfo: nil))
            return
        }
        var parameters = [
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
                saveUser(json!)
                completion(nil)
            }
        }
    }
    
    // MARK: - Profile -
    
    class func getProfile(for user: User? = nil, completion:@escaping (NSError?, User?)->()) {
        var parameters: Parameters = [:]
        if let id = user?.id {
            parameters["id"] = id
        }
        request(urlAddition: "users/profile", method: .get, parameters: parameters, needsToken: true)
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
            parameters["type"] = "manager"
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
    
    class func get(project: Project, completion:@escaping (NSError?, Project?)->()) {
        guard let id = project.id else { return }

        let parameters: Parameters = [
            "projectid": id
        ]
        
        request(urlAddition: "projects/project", method: .get, parameters: parameters, needsToken: true)
        { json, error in
            completion(error, Project(json: json))
        }
    }
    
    class func getInvites(completion:@escaping (NSError?, [Invite]?)->()) {
        request(urlAddition: "projects/invites", method: .get, needsToken: true)
        { json, error in
            completion(nil, [])
            completion(error, Invite.map(json: json))
        }
    }
    
    class func invite(approve: Bool, invite: Invite, completion: @escaping (NSError?)->()) {
        let parameters: Parameters = [
            "inviteid": invite.id,
            "accept": approve ? 1 : 0
        ]
        
        request(urlAddition: "projects/invite", method: .post, parameters: parameters, needsToken: true)
        { json, error in
            completion(error)
        }
    }
    
    class func remove(manager: User, from project: Project, completion:@escaping (NSError?)->()) {
        guard let id = project.id else { return }
        
        let parameters: Parameters = [
            "managerid": manager.id,
            "projectid": id
        ]
        
        request(urlAddition: "projects/manager", method: .delete, parameters: parameters, needsToken: true)
        { json, error in
            completion(error)
        }
    }
    
    class func remove(client: User, from project: Project, completion:@escaping (NSError?)->()) {
        guard let id = project.id else { return }
        
        let parameters: Parameters = [
            "clientid": client.id,
            "projectid": id
        ]
        
        request(urlAddition: "projects/client", method: .delete, parameters: parameters, needsToken: true)
        { json, error in
            completion(error)
        }
    }
    
    class func remove(invite: Invite, completion:@escaping (NSError?)->()) {
        let parameters: Parameters = [
            "inviteid": invite.id,
        ]
        
        request(urlAddition: "projects/invite", method: .delete, parameters: parameters, needsToken: true)
        { json, error in
            completion(error)
        }
    }
    
    class func add(clients: [String], to project: Project, completion:@escaping (NSError?)->()) {
        guard let id = project.id else { return }
        
        let parameters: Parameters = [
            "projectid": id,
            "clients": clients
        ]
        
        request(urlAddition: "projects/clients", method: .post, parameters: parameters, needsToken: true)
        { json, error in
            completion(error)
        }
    }
    
    class func add(managers: [String], to project: Project, completion:@escaping (NSError?)->()) {
        guard let id = project.id else { return }
        
        let parameters: Parameters = [
            "projectid": id,
            "managers": managers
        ]
        
        request(urlAddition: "projects/managers", method: .post, parameters: parameters, needsToken: true)
        { json, error in
            completion(error)
        }
    }
    
    class func change(status: String, project: Project, completion:@escaping (NSError?, Post?)->()) {
        guard let id = project.id else { return }
        
        let parameters = [
            "projectid": id,
            "text": status,
            "type": "status"
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
    
    class func edit(project: Project, progress:@escaping (Float)->(), completion:@escaping (NSError?)->()) {
        if isDemo() {
            completion(NSError(domain: "You can't do that in demo account", code: 403, userInfo: nil))
            return
        }
        
        var parameters: Parameters = [
            "projectid": project.id!,
            "title": project.tempTitle ?? project.title ?? "",
            "description": project.tempProjectDescription ?? project.projectDescription ?? "",
        ]
        
        if let key = project.imageKey {
            parameters["image"] = key
        }
        
        if let image = project.tempImage {
            S3.upload(image: image, progress: progress)
            { key, error in
                if let error = error {
                    completion(NSError(domain: error, code: 500, userInfo: nil))
                } else if let key = key {
                    parameters["image"] = key
                    request(urlAddition: "projects", method: .put, parameters: parameters, needsToken: true)
                    { json, error in
                        completion(error)
                    }
                }
            }
        } else {
            
            request(urlAddition: "projects", method: .put, parameters: parameters, needsToken: true)
            { json, error in
                
                completion(error)
            }
        }
    }
    
    class func toggleFinished(for project: Project, completion: @escaping (NSError?)->()) {
        guard let id = project.id else {return }
        
        let parameters: Parameters = [
            "projectid": id
        ]
        
        if isDemo() {
            completion(NSError(domain: NSLocalizedString("You can't do that in demo account", comment: "Error"), code: 500, userInfo: nil))
            return
        }
        
        let urlAddition = project.isFinished ? "projects/revive" : "projects/finish"
        request(urlAddition: urlAddition, method: .post, parameters: parameters, needsToken: true)
        { json, error in
            completion(error)
        }
    }
    
    class func delete(project: Project, completion: @escaping (NSError?)->()) {
        guard let id = project.id else { return }

        if isDemo() {
            completion(NSError(domain: NSLocalizedString("You can't do that in demo account", comment: "Error"), code: 500, userInfo: nil))
            return
        }

        let parameters: Parameters = [
            "projectid": id
        ]
        
        request(urlAddition: "projects", method: .delete, parameters: parameters, needsToken: true)
        { json, error in
            completion(error)
        }
    }
    
    class func leave(project: Project, completion: @escaping (NSError?)->()) {
        guard let id = project.id else { return }
        let parameters: [String: String] = [
            "projectid": id
        ]
        
        if isDemo() {
            completion(NSError(domain: "You can't leave the demo project", code: 403, userInfo: nil))
            return
        }
        
        if project.isOwner {
            completion(NSError(domain: "You can't leave project as an owner", code: 403, userInfo: nil))
            return
        }
        
        
        request(urlAddition: "projects/leave", method: .post, parameters: parameters, needsToken: true)
        { json, error in
            completion(error)
        }
        
    }
    
    // MARK: - Posts -
    
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
    
    // MARK: - Payments -
    
    class func stripeGetCustomer(completion: @escaping (DefaultDataResponse?, NSError?)->()) {
        let parameters: Parameters = [
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
    
    // MARK: - Misc -
    
    class func features(completion: @escaping (JSON?, NSError?)->()) {
        request(urlAddition: "feature_list", method: .get, needsToken: false)
        { json, error in
            completion(json, error)
        }
    }
    
    class func fetchErrorsLocalizations() {
        errorsLocalizations
        { json, error in
            if let json = json {
                UserDefaults.set(json.dictionaryObject, key: "localizedErrors")
            }
        }
    }
    
    class func errorsLocalizations(completion: @escaping (JSON?, NSError?)->()) {
        request(urlAddition: "error_list", method: .get, needsToken: false)
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
                DispatchQueue.main.async {
                    if let errorString = response.result.error?.localizedDescription {
                        completion(nil, NSError(domain: errorString, code: 500, userInfo: nil))
                    } else if let value = response.result.value, let error = checkForErrors(json: JSON(value)) {
                        completion(nil, error)
                    } else if response.response?.statusCode == 500 {
                        completion(nil, NSError(domain: NSLocalizedString("Server error", comment: "Error"), code: 500, userInfo: nil))
                    } else if let value = response.result.value {
                        completion(JSON(value), nil)
                    }
                }
        }
    }
    
    fileprivate class func requestData(urlAddition: String, method: HTTPMethod, parameters: [String:Any]? = nil, needsToken: Bool, completion: @escaping (DefaultDataResponse?, NSError?)->()) {
        Alamofire.request(apiUrl + urlAddition, method: method, parameters: parameters, encoding: method == .get ? URLEncoding.default : JSONEncoding.default, headers: headers(needsToken: needsToken))
            .response { response in
                DispatchQueue.main.async {
                    if let errorString = response.error?.localizedDescription {
                        completion(nil, NSError(domain: errorString, code: 500, userInfo: nil))
                    } else if let data = response.data, let error = self.checkForErrors(json: JSON(data)) {
                        completion(nil, error)
                    } else if response.response?.statusCode == 500 {
                        completion(nil, NSError(domain: NSLocalizedString("Server error", comment: "Error"), code: 500, userInfo: nil))
                    } else {
                        completion(response, nil)
                    }
                }
        }
    }
    
    fileprivate class func checkForErrors(json: JSON) -> NSError? {
        let langCode = Locale.current.languageCode ?? "en"
        if let type = json["type"].string,
            let errors = UserDefaults.get("localizedErrors") as? [String: Any],
            let messageDictionary = errors[type] as? [String: String],
            let message = messageDictionary[langCode] {
            return NSError(domain: message, code: json["status"].int ?? 500, userInfo: nil)
        } else if let message = json["message"].string {
            return NSError(domain: message, code: json["status"].int ?? 500, userInfo: nil)
        } else {
            return nil
        }
    }
    
    fileprivate class func headers(needsToken: Bool) -> [String:String] {
        return needsToken ?
            ["apiKey": apiKey, "token": currentUser?.token ?? ""] :
            ["apiKey": apiKey]
    }
}
