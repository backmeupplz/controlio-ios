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
    
    var stripeId: String?
    var plan: Plan!
    
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
    
    func equals(compareTo: User?) -> Bool {
        guard compareTo != nil else {
            return false
        }
        return
            self.email == compareTo?.email &&
            self.name == compareTo?.name &&
            self.phone == compareTo?.phone &&
            self.tempProfileImage == compareTo?.tempProfileImage
    }
    
    func copy(zone: NSZone? = nil) -> User {
        let copy = User()
        copy.email = self.email
        copy.id = self.id
        copy.name = self.name
        copy.phone = self.phone
        copy.profileImageKey = self.profileImageKey
        copy.profileImageKey = self.profileImageKey
        copy.isBusiness = self.isBusiness
        copy.addedAsManager = self.addedAsManager
        copy.addedAsClient = self.addedAsClient
        copy.emailVerified = self.emailVerified
        copy.profileCompleted = self.profileCompleted
        copy.isAdmin = self.isAdmin
        copy.isDemo = self.isDemo
        
        return copy
    }
    
    class func map(json: JSON?) -> [User]? {
        guard let array = json?.array else { return nil }
        return array.flatMap { User(json: $0) }
    }
    
    convenience init?(json: JSON?) {
        guard let json = json, !json.isEmpty, let id = json["_id"].string else { return nil }
        
        self.init()
        
        email = json["email"].string!
        self.id = id
        
        stripeId = json["stripeId"].string
        plan = Plan(rawValue: (json["plan"].int ?? 0))
        
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
        
        aCoder.encode(stripeId, forKey: "stripeId")
        aCoder.encode(plan.rawValue, forKey: "plan")
        
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
        
        stripeId = aDecoder.decodeObject(forKey: "stripeId") as? String
        plan = Plan(rawValue: aDecoder.decodeInteger(forKey: "plan"))
        
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
