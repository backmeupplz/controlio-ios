//
//  Project.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 08/05/16.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit
import SwiftyJSON

class Project: NSObject {
    
    // MARK: - Variables -
    
    var id: String?
    
    var title: String?
    var projectDescription: String?
    var imageKey: String?
    var dateCreated: Date?
    var dateUpdated: Date?
    
    var owner: User?
    var managers = [User]()
    var clients = [User]()
    
    var invites = [Invite]()
    var ownerInvited: Invite? {
        get {
            return invites.filter { $0.type == .own }.last
        }
    }
    var clientsInvited: [Invite] {
        get {
            return invites.filter { $0.type == .client }
        }
    }
    var managersInvited: [Invite] {
        get {
            return invites.filter { $0.type == .manage }
        }
    }
    
    var lastStatus: Post?
    var lastPost: Post?
    
    var canEdit: Bool = false
    var isFinished = false
    var isOwner: Bool {
        get {
            return owner != nil && owner?.id == Server.currentUser?.id
        }
    }
    
    var tempType = NewProjectCellType.client
    var tempImage: UIImage?
    var tempInitialStatus: String?
    var tempManagerEmail: String?
    var tempClientEmails = [String]()
    
    // MARK: - Functions -

    func isEqual(to project: Project?) -> Bool {
        guard let project = project else {
            return false
        }
        
        return
            title == project.title &&
            id == project.id &&
            projectDescription == project.projectDescription &&
            tempImage == project.tempImage
    }
    
    func copy(zone: NSZone? = nil) -> Project {
        let copy = Project()
        copy.id = id
        copy.title = title
        copy.projectDescription = projectDescription
        copy.imageKey = imageKey
        copy.tempImage = tempImage
        copy.dateCreated = dateCreated
        copy.dateUpdated = dateUpdated
        copy.managers = managers
        copy.clients = clients
        copy.owner = owner
        copy.invites = invites
        return copy
    }
    
    
    class func map(json: JSON?) -> [Project]? {
        guard let array = json?.array else { return nil }
        return array.flatMap { Project(json: $0) }
    }
    
    convenience init?(json: JSON?) {
        guard let json = json, !json.isEmpty, let id = json["_id"].string else { return nil }
        
        self.init()
        
        self.id = id
        
        title = json["title"].string!
        projectDescription = json["description"].string
        imageKey = json["image"].string
        dateCreated = json["createdAt"].string!.dateFromISO8601
        dateUpdated = json["updatedAt"].string!.dateFromISO8601
        
        owner = User(json: json["owner"])
        clients = User.map(json: json["clients"]) ?? []
        managers = User.map(json: json["managers"]) ?? []
        
        invites = Invite.map(json: json["invites"]) ?? []
        
        lastPost = Post(json: json["lastPost"])
        lastStatus = Post(json: json["lastStatus"])
        
        canEdit = json["canEdit"].bool ?? false
        isFinished = json["isFinished"].bool ?? false
    }
}
