//
//  ServerManager.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 17/05/15.
//  Copyright (c) 2015 Borodutch Studio LLC. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class ServerManager {
    static let sharedInstance = ServerManager()
    var token: NSString?
    
    func auth(login: String, password: String, completion:(NSError?)->()) {
        Alamofire.request(.POST, "http://dev.zachot.me/boro/ios/auth", parameters: ["login": login, "password": password])
            .response { (request, response, data, error) in
                
                if (error == nil) {
                    let json = JSON(data!)
                    println(json["access_token"].stringValue)
                } else {
                    println("server error: \(error!.description)")
                }
                completion(error)
        }
    }
}
