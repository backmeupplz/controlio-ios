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
    
    // MARK: - Singleton -
    
    static let sharedManager = Server()
    
    // MARK: - Properties -
    
    var userId: String? {
        set {
            UserDefaults.set(newValue as AnyObject?, key: "userId")
        }
        get {
            return UserDefaults.getString("userId")
        }
    }
    
    var token: String? {
        set {
            UserDefaults.set(newValue as AnyObject?, key: "token")
        }
        get {
            return UserDefaults.getString("token")
        }
    }
    
    // MARK: - Internal functions -
    
    func isLoggedIn() -> Bool {
        return userId != nil && token != nil
    }
    
    func signup(_ email: String, password: String, completion:@escaping (String?)->()) {
        let parameters = [
            "email": email,
            "password": password
        ]
        
        Alamofire.request(apiUrl + "/users", method: .post, parameters: parameters, headers: headers())
            .responseJSON { response in
                if let message = response.result.error?.localizedDescription {
                    completion(message)
                } else {
                    let json = JSON(response.result.value!)
                    if let message = json["message"].string {
                        completion(message)
                    } else {
                        self.saveUser(json)
                        completion(nil)
                    }
                }
        }
    }
    
    func login(_ email: String, password: String, completion:@escaping (String?)->()) {
        let parameters = [
            "email": email,
            "password": password
        ]
        
        Alamofire.request(apiUrl + "/users/login", method: .post, parameters: parameters, headers: headers())
            .responseJSON { response in
                if let message = response.result.error?.localizedDescription {
                    completion(message)
                } else {
                    let json = JSON(response.result.value!)
                    if let message = json["message"].string {
                        completion(message)
                    } else {
                        self.saveUser(json)
                        completion(nil)
                    }
                }
        }
    }
    
    // MARK: - Private functions -
    
    fileprivate func saveUser(_ user: JSON) {
        token = user["token"].string!
        userId = user["_id"].string!
    }
    
    fileprivate func headers() -> [String:String] {
        return [
            "x-access-apiKey": apiKey,
        ]
    }
}
