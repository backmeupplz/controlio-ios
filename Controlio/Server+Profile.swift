//
//  Server+Profile.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 27/04/2017.
//  Copyright © 2017 Nikita Kolmogorov. All rights reserved.
//

import UIKit
import Alamofire

extension Server {
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
}
