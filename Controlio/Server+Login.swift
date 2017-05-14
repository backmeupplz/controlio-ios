//
//  Server+Login.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 27/04/2017.
//  Copyright © 2017 Nikita Kolmogorov. All rights reserved.
//

import UIKit
import Alamofire

extension Server {
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
    
    class func loginFacebook(accessToken: String, completion:@escaping (NSError?)->()) {
        var parameters = [
            "access_token": accessToken
        ]
        if let pushNotificationsToken = pushNotificationsToken {
            parameters["iosPushToken"] = pushNotificationsToken
        }
        
        request(urlAddition: "users/loginFacebook", method: .post, parameters: parameters, needsToken: false)
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
}
