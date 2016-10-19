//
//  User.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 08/05/16.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit
import SwiftyJSON

class User: NSObject, NSCoding {
    
    // MARK: - Variables -
    
    var email: String!
    var id: String!
    
    var token: String?
    
    var name: String?
    var phone: String?
    var profileImageKey: String?
    var tempProfileImage: UIImage?
    
    var isBusiness = false
    var addedAsManager = false
    var addedAsClient = false
    var emailVerified = false
    var profileCompleted = false
    var isAdmin = false
    var isDemo = false
    
    // MARK: - Functions -
    
    class func map(json: JSON?) -> [User]? {
        guard let json = json else { return nil }
        return json.array!.map { User(json: $0) }
    }
    
    convenience init(json: JSON) {
        self.init()
        
        email = json["email"].string!
        id = json["_id"].string!
        
        token = json["token"].string
        
        name = json["name"].string
        phone = json["phone"].string
        if let profileImageKeyString = json["photo"].string {
            profileImageKey = profileImageKeyString
        }
        
        isBusiness = json["isBusiness"].bool ?? false
        addedAsManager = json["addedAsManager"].bool ?? false
        addedAsClient = json["addedAsClient"].bool ?? false
        emailVerified = json["isEmailVerified"].bool ?? false
        profileCompleted = json["isCompleted"].bool ?? false
        isAdmin = json["isAdmin"].bool ?? false
        
        isDemo = json["isDemo"].bool ?? false
    }
    
    // MARK: - NSCoding -
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(email, forKey: "email")
        aCoder.encode(id, forKey: "id")
        
        aCoder.encode(token, forKey: "token")
        
        aCoder.encode(name, forKey: "name")
        aCoder.encode(phone, forKey: "phone")
        aCoder.encode(profileImageKey, forKey: "profileImageKey")
        
        aCoder.encode(isBusiness, forKey: "isBusiness")
        aCoder.encode(addedAsManager, forKey: "addedAsManager")
        aCoder.encode(addedAsClient, forKey: "addedAsClient")
        aCoder.encode(emailVerified, forKey: "emailVerified")
        aCoder.encode(profileCompleted, forKey: "profileCompleted")
        aCoder.encode(isAdmin, forKey: "isAdmin")
        aCoder.encode(isDemo, forKey: "isDemo")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        
        email = aDecoder.decodeObject(forKey: "email") as! String
        id = aDecoder.decodeObject(forKey: "id") as! String
        
        token = aDecoder.decodeObject(forKey: "token") as? String
        
        name = aDecoder.decodeObject(forKey: "name") as? String
        phone = aDecoder.decodeObject(forKey: "phone") as? String
        profileImageKey = aDecoder.decodeObject(forKey: "profileImageKey") as? String
        
        isBusiness = aDecoder.decodeObject(forKey: "isBusiness") as? Bool ?? false
        addedAsManager = aDecoder.decodeObject(forKey: "addedAsManager") as? Bool ?? false
        addedAsClient = aDecoder.decodeObject(forKey: "addedAsClient") as? Bool ?? false
        emailVerified = aDecoder.decodeObject(forKey: "emailVerified") as? Bool ?? false
        profileCompleted = aDecoder.decodeObject(forKey: "profileCompleted") as? Bool ?? false
        isAdmin = aDecoder.decodeObject(forKey: "isAdmin") as? Bool ?? false
        isDemo = aDecoder.decodeBool(forKey: "isDemo")
    }
}
