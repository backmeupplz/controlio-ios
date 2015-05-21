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
import UIKit

class ServerManager {
    
    // MARK: - Singleton -
    
    static let sharedInstance = ServerManager()
    
    // MARK: - Variables -
    
    var token: String? {
        didSet {
            NSUserDefaults.standardUserDefaults().setObject(token, forKey: UDToken)
            println("Set token to: \(token)")
        }
    }
    
    // MARK: - Public Methods -
    
    func auth(login: String, password: String, completion:(NSError?)->()) {
        Alamofire.request(.POST, "http://dev.zachot.me/boro/ios/auth", parameters: ["login": login, "password": password])
            .responseJSON { (request, response, json, error) in
                if (error == nil) {
                    let js = JSON(json!)
                    self.token = js["access_token"].string
                } else {
                    self.showError(error!)
                }
                completion(error)
        }
    }
    
    func logout() {
        token = nil
    }
    
    func getProjects(offset: Int, count: Int, completion:(NSError?, [ProjectObject]?)->()) {
        
        var params = self.appendToken(["offset": offset, "count": count]) as! [String: AnyObject]
        
        Alamofire.request(.POST, "http://dev.zachot.me/boro/ios/project", parameters: params)
            .responseJSON { (request, response, json, error) in
                if (error == nil) {
                    let js = JSON(json!)
                    completion(nil,self.convertJsonToProjectObjects(js))
                } else {
                    self.showError(error!)
                    completion(error, nil)
                }
        }
    }
    
    // MARK: - Private Methods -

    func appendToken(params: NSDictionary) -> NSDictionary {
        if (token == nil) {
            return params
        } else {
            var temp = params as! [String : AnyObject]
            temp["access_token"] = token!
            return temp
        }
    }
    
    func showError(error: NSError) {
        var alert = UIAlertController(title: "Ошибочка", message: error.localizedDescription, preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Ясно!", style: .Cancel) { action -> Void in
            
        }
        alert.addAction(cancelAction)
        
        let logoutAction: UIAlertAction = UIAlertAction(title: "Отправить отчет разработчикам", style: .Default) { action -> Void in
            
        }
        alert.addAction(logoutAction)
        
        UIApplication.sharedApplication().keyWindow!.rootViewController?.presentViewController(alert, animated: true, completion: nil)
    }
    
    func convertJsonToProjectObjects(json: JSON) -> [ProjectObject] {
        var result = [ProjectObject]()
        for jsonObject in json.arrayValue {
            result.append(ProjectObject.convertJsonToObject(jsonObject))
        }
        return result
    }
}