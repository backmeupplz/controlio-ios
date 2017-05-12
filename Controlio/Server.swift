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
import Stripe

enum ProjectSearchType: String {
    case all = "all"
    case live = "live"
    case finished = "finished"
}

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
    
    class func saveUser(_ user: JSON) {
        currentUser = User(json: user)
    }
    
    class func features(completion: @escaping (JSON?, NSError?)->()) {
        let _ = request(urlAddition: "feature_list", method: .get, needsToken: false)
        { json, error in
            completion(json, error)
        }
    }
    
    class func fetchErrorsLocalizations() {
        let _ = errorsLocalizations
        { json, error in
            if let json = json {
                UserDefaults.set(json.dictionaryObject, key: "localizedErrors")
            }
        }
    }
    
    class func errorsLocalizations(completion: @escaping (JSON?, NSError?)->()) {
        let _ = request(urlAddition: "error_list", method: .get, needsToken: false)
        { json, error in
            completion(json, error)
        }
    }
    
    @discardableResult class func request(urlAddition: String, method: HTTPMethod, parameters: [String:Any]? = nil, needsToken: Bool, completion: @escaping (JSON?, NSError?)->()) -> DataRequest {
        return Alamofire.request(apiUrl + urlAddition, method: method, parameters: parameters, encoding: method == .get ? URLEncoding.default : JSONEncoding.default, headers: headers(needsToken: needsToken))
            .debugLog()
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
    
    class func requestData(urlAddition: String, method: HTTPMethod, parameters: [String:Any]? = nil, needsToken: Bool, completion: @escaping (DefaultDataResponse?, NSError?)->()) {
        Alamofire.request(apiUrl + urlAddition, method: method, parameters: parameters, encoding: method == .get ? URLEncoding.default : JSONEncoding.default, headers: headers(needsToken: needsToken))
            .debugLog()
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
    
    // MARK: - Private functions -
    
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
