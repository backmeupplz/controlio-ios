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
            print("Set token to: \(token)")
        }
    }
    
    // MARK: - Public Methods -
    
    func auth(login: String, password: String, completion:(NSError?)->()) {
        Alamofire.request(.POST, serverURL+"auth", parameters: ["login": login, "password": password])
            .responseJSON { (request, response, result) in
                var err: NSError?
                switch result {
                case .Success:
                    let js = JSON(result.value!)
                    
                    if (js["error"].bool == true) {
                        let code: Int = js["code"].int!
                        switch code {
                        case 0:
                            self.showErrorMessage(NSLocalizedString("No login or password specified", comment: ""))
                        case 1:
                            self.showErrorMessage(NSLocalizedString("Wrong login", comment: ""))
                        case 2:
                            self.showErrorMessage(NSLocalizedString("Wrong password", comment: ""))
                        default:
                            break
                        }
                        err = NSError(domain: "Authentication failed", code: 0, userInfo: nil)
                    } else {
                        self.token = js["access_token"].string
                    }
                case .Failure(_):
                    err = result.error as? NSError
                    self.showError(err!)
                }
                completion(err)
        }
    }
    
    func resetPass(login: String, completion:(NSError?)->()) {
        Alamofire.request(.POST, serverURL+"reset-password", parameters: ["login": login])
            .responseJSON { (request, response, result) in
                var err: NSError?
                switch result {
                case .Success:
                    let js = JSON(result.value!)
                    
                    if (js["error"].bool == true) {
                        self.showErrorMessage(NSLocalizedString("Unable to perform action", comment: ""))
                        err = NSError(domain: "Resetting pass failed", code: 0, userInfo: nil)
                    }
                case .Failure(_):
                    err = NSError(domain: "Resetting pass failed", code: 0, userInfo: nil)
                    self.showError(err!)
                }
                completion(err)
            }
    }
    
    func changePass(login: String, oldPass: String, newPass: String, completion:(NSError?)->()) {
        Alamofire.request(.POST, serverURL+"change-password", parameters: ["login": login, "password": oldPass, "new_password": newPass])
            .responseJSON { (request, response, result) in
                var err: NSError?
                switch result {
                case .Success:
                    let js = JSON(result.value!)
                    if (js["error"].bool == true) {
                        self.showErrorMessage(NSLocalizedString("Unable to change password", comment: ""))
                        err = NSError(domain: "Unable to change password", code: 0, userInfo: nil)
                    }
                case .Failure(_):
                    err = NSError(domain: "Unable to change password", code: 0, userInfo: nil)
                    self.showError(err!)
                }
                completion(err)
            }
    }
    
    func logout() {
        PushNotificationsManager.sharedInstance.logout()
        token = nil
    }
    
    func getProjects(offset: Int, count: Int, completion:(NSError?, [ProjectObject]?)->()) {
        let params = self.appendToken(["offset": offset, "count": count])
        Alamofire.request(.POST, serverURL+"project", parameters: params)
            .responseJSON { (request, response, result) in
                switch result {
                case .Success:
                    let js = JSON(result.value!)
                    completion(nil,self.convertJsonToProjectObjects(js))
                case .Failure(_):
                    let err = NSError(domain: "Could not get list of projects", code: 0, userInfo: nil)
                    self.showError(err)
                    completion(err, nil)
                }
                
            }
    }
    
    func getStatuses(projectid: Int, offset: Int, count: Int, completion:(NSError?, [StatusObject]?)->()) {
        let params = self.appendToken(["project": projectid, "offset": offset, "count": count])
        Alamofire.request(.POST, serverURL+"posts", parameters: params)
            .responseJSON { (request, response, result) in
                switch result {
                case .Success:
                    let js = JSON(result.value!)
                    completion(nil,self.convertJsonToStatusObjects(js))
                case .Failure(_):
                    let err = NSError(domain: "Could not get statuses", code: 0, userInfo: nil)
                    self.showError(err)
                    completion(err, nil)
                }
            }
    }
    
    func sendPost(projectid: Int, image: UIImage?, text: String, completion:NSError?->()) {
        let params = self.appendToken(["project": projectid, "offset": 10, "count": 10])
        Alamofire.request(.POST, serverURL+"posts", parameters: params)
            .responseJSON { (request, response, result) in
                switch result {
                case .Success:
                    completion(nil)
                case .Failure(_):
                    completion(nil)
                }
            }
    }
    
    func sendStatus(projectid: Int, text: String, completion:NSError?->()) {
        let params = self.appendToken(["project": projectid, "offset": 10, "count": 10])
        Alamofire.request(.POST, serverURL+"posts", parameters: params)
            .responseJSON { (request, response, result) in
                switch result {
                case .Success:
                    completion(nil)
                case .Failure(_):
                    completion(nil)
                }
            }
    }
    
    func addPushTokenToServer(pushToken: String) {
        let params = self.appendToken(["device_token": pushToken])
        Alamofire.request(.POST, serverURL+"register-push-token", parameters: params)
    }
    
    func deletePushTokenFromServer(pushToken: String) {
        let params = self.appendToken(["device_token": pushToken])
        Alamofire.request(.POST, serverURL+"remove-push-token", parameters: params)
    }
    
    // MARK: - Private Methods -

    func appendToken(params: [String: AnyObject]) -> [String: AnyObject] {
        if (token == nil) {
            return params
        } else {
            var temp = params
            temp["access_token"] = token!
            return temp
        }
    }
    
    func showError(error: NSError) {
        showErrorMessage(error.localizedDescription)
    }
    
    func showErrorMessage(error: String) {
        let alert = UIAlertController(title: NSLocalizedString("Ошибочка", comment:""), message: error, preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Ясно!", comment:""), style: .Cancel) { action -> Void in
            
        }
        alert.addAction(cancelAction)
        
        let logoutAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Отправить отчет разработчикам", comment:""), style: .Default) { action -> Void in
            
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
    
    func convertJsonToStatusObjects(json: JSON) -> [StatusObject] {
        var result = [StatusObject]()
        for jsonObject in json.arrayValue {
            result.append(StatusObject.convertJsonToObject(jsonObject))
        }
        return result
    }
}