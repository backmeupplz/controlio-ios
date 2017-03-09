//
//  Invite.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 20/01/2017.
//  Copyright © 2017 Nikita Kolmogorov. All rights reserved.
//

import UIKit
import SwiftyJSON

enum InviteType: String {
    case manage = "manage"
    case own = "own"
    case client = "client"
}

class Invite: NSObject {
    
    // MARK: - Variables -
    
    var id: String!
    var type = InviteType.manage
    var sender: User?
    var project: Project?
    var invitee: User?
    
    // MARK: - Functions -
    
    class func map(json: JSON?) -> [Invite]? {
        guard let array = json?.array else { return nil }
        return array.flatMap { Invite(json: $0) }
    }
    
    convenience init?(json: JSON?) {
        guard let json = json, !json.isEmpty, let id = json["_id"].string else { return nil }
        
        self.init()
        
        self.id = id
        type = InviteType(rawValue: json["type"].string!)!
        sender = User(json: json["sender"])
        project = Project(json: json["project"])
        invitee = User(json: json["invitee"])
    }
}
