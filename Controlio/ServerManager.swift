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
        Alamofire.request(.POST, serverURL+"auth", parameters: ["login": login, "password": password])
            .responseJSON { (request, response, json, error) in
                var err = error
                if (error == nil) {
                    let js = JSON(json!)
                    
                    if (js["error"].bool == true) {
                        var code: Int = js["code"].int!
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
                        err = NSError()
                    } else {
                        self.token = js["access_token"].string
                    }
                } else {
                    self.showError(err!)
                }
                completion(err)
        }
    }
    
    func resetPass(login: String, completion:(NSError?)->()) {
        Alamofire.request(.POST, serverURL+"reset-password", parameters: ["login": login])
            .responseJSON { (request, response, json, error) in
                var err = error
                if (error == nil) {
                    let js = JSON(json!)
                    
                    if (js["error"].bool == true) {
                        self.showErrorMessage(NSLocalizedString("Unable to perform action", comment: ""))
                        err = NSError()
                    } else {
                        self.showErrorMessage(NSLocalizedString("Check your email, we reset your password", comment: ""))
                    }
                } else {
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
        var params = self.appendToken(["offset": offset, "count": count])
        Alamofire.request(.POST, serverURL+"project", parameters: params)
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
    
    func getStatuses(projectid: Int, offset: Int, count: Int, completion:(NSError?, [StatusObject]?)->()) {
        var params = self.appendToken(["project": projectid, "offset": offset, "count": count])
        Alamofire.request(.POST, serverURL+"posts", parameters: params)
            .responseJSON { (request, response, json, error) in
                if (error == nil) {
                    let js = JSON(json!)
                    completion(nil,self.convertJsonToStatusObjects(js))
                } else {
                    self.showError(error!)
                    completion(error, nil)
                }
        }
    }
    
    func sendPost(projectid: Int, image: UIImage?, text: String, completion:NSError?->()) {
        var params = self.appendToken(["project": projectid, "offset": 10, "count": 10])
        Alamofire.request(.POST, serverURL+"posts", parameters: params)
            .responseJSON { (request, response, json, error) in
                if (error == nil) {
                    let js = JSON(json!)
                    completion(nil)
                } else {
                    self.showError(error!)
                    completion(error)
                }
        }
    }
    
    func sendStatus(projectid: Int, text: String, completion:NSError?->()) {
        var params = self.appendToken(["project": projectid, "offset": 10, "count": 10])
        Alamofire.request(.POST, serverURL+"posts", parameters: params)
            .responseJSON { (request, response, json, error) in
                if (error == nil) {
                    let js = JSON(json!)
                    completion(nil)
                } else {
                    self.showError(error!)
                    completion(error)
                }
        }
    }
    
    func addPushTokenToServer(pushToken: String) {
        var params = self.appendToken(["device_token": pushToken])
        Alamofire.request(.POST, serverURL+"register-push-token", parameters: params)
    }
    
    func deletePushTokenFromServer(pushToken: String) {
        var params = self.appendToken(["device_token": pushToken])
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
        var alert = UIAlertController(title: NSLocalizedString("Ошибочка", comment:""), message: error, preferredStyle: .Alert)
        
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
        var previousTimestamp: Int?
        for jsonObject in json.arrayValue {
            var status = StatusObject.convertJsonToObject(jsonObject)
            var timestamp = status.timestamp - (status.timestamp % (60*60*24))
            if (previousTimestamp == nil) {
                result.append(StatusObject.timeStatus(timestamp))
            } else if (previousTimestamp != timestamp) {
                result.append(StatusObject.timeStatus(timestamp))
            }
            result.append(status)
            previousTimestamp = timestamp
        }
        return result
    }
}