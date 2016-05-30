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

class Server: NSObject {
    
    // MARK: - Singleton -
    
    static let sharedManager = Server()
    
    // MARK: - Properties -
    
    var userId: String? {
        set {
            NSUserDefaults.set(newValue, key: "userId")
        }
        get {
            return NSUserDefaults.getString("userId")
        }
    }
    
    var token: String? {
        set {
            NSUserDefaults.set(newValue, key: "token")
        }
        get {
            return NSUserDefaults.getString("token")
        }
    }
    
    // MARK: - Internal fucntions -
    
    func isLoggedIn() -> Bool {
        return userId != nil && token != nil
    }
    
    func signup(email: String, password: String, completion:(String?)->()) {
        let parameters = [
            "email": email,
            "password": password
        ]
        
        Alamofire.request(.POST, apiUrl + "/users", parameters: parameters, headers: headers())
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
    
    func login(email: String, password: String, completion:(String?)->()) {
        let parameters = [
            "email": email,
            "password": password
        ]
        
        Alamofire.request(.POST, apiUrl + "/users/login", parameters: parameters, headers: headers())
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
    
    private func saveUser(user: JSON) {
        token = user["token"].string!
        userId = user["_id"].string!
    }
    
    private func headers() -> [String:String] {
        return [
            "x-access-apiKey": apiKey,
        ]
    }
}
