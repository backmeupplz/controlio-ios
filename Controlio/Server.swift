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
    
    // MARK: - Managers -
    
    class func getManagers(completion:@escaping (NSError?, [User]?)->()) {
        request(urlAddition: "users/managers", method: .get, needsToken: true)
        { json, error in
            if let error = error {
                completion(error, nil)
            } else {
                completion(nil, User.map(json: json!))
            }
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
    
    // MARK: - Private functions -
    
    fileprivate class func request(urlAddition: String, method: HTTPMethod, parameters: [String:String]? = nil, needsToken: Bool, completion: @escaping (JSON?, NSError?)->()) {
        Alamofire.request(apiUrl + urlAddition, method: method, parameters: parameters, encoding: JSONEncoding.default, headers: headers(needsToken: needsToken))
            .responseJSON { response in
                if let errorString = response.result.error?.localizedDescription {
                    completion(nil, NSError(domain: errorString, code: 500, userInfo: nil))
                } else if let error = checkForErrors(json: JSON(response.result.value)) {
                    completion(nil, error)
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
