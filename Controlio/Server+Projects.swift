//
//  Server+Projects.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 27/04/2017.
//  Copyright © 2017 Nikita Kolmogorov. All rights reserved.
//

import UIKit
import Alamofire

extension Server {
    class func add(project: Project, progress:@escaping (Float)->(), completion:@escaping (NSError?)->()) {
        if isDemo() {
            completion(NSError(domain: "You can't do that in demo account", code: 403, userInfo: nil))
            return
        }
        
        var parameters: Parameters = [
            "title": project.title!,
            "progressEnabled": project.tempProgressEnabled
        ]
        if project.tempType == .client {
            parameters["type"] = "client"
            parameters["managerEmail"] = project.tempManagerEmail
        } else {
            parameters["type"] = "manager"
            parameters["clientEmails"] = project.tempClientEmails
        }
        if let description = project.projectDescription {
            parameters["description"] = description
        }
        if let initialStatus = project.tempInitialStatus {
            parameters["initialStatus"] = initialStatus
        }
        
        if let image = project.tempImage {
            S3.upload(image: image, progress: progress)
            { key, error in
                if let error = error {
                    completion(NSError(domain: error, code: 500, userInfo: nil))
                } else if let key = key {
                    parameters["image"] = key
                    request(urlAddition: "projects", method: .post, parameters: parameters, needsToken: true)
                    { json, error in
                        completion(error)
                    }
                }
            }
        } else {
            request(urlAddition: "projects", method: .post, parameters: parameters, needsToken: true)
            { json, error in
                completion(error)
            }
        }
    }
    
    class func getProjects(skip: Int = 0, limit: Int = 20, type: ProjectSearchType = .all, query: String = "", completion:@escaping (NSError?, [Project]?)->()) {
        let parameters: Parameters = [
            "skip": skip,
            "limit": limit,
            "query": query,
            "type": type.rawValue
        ]
        request(urlAddition: "projects", method: .get, parameters: parameters, needsToken: true)
        { json, error in
            completion(error, Project.map(json: json))
        }
    }
    
    class func get(project: Project, completion:@escaping (NSError?, Project?)->()) {
        guard let id = project.id else { return }
        
        let parameters: Parameters = [
            "projectid": id
        ]
        
        request(urlAddition: "projects/project", method: .get, parameters: parameters, needsToken: true)
        { json, error in
            completion(error, Project(json: json))
        }
    }
    
    class func getInvites(completion:@escaping (NSError?, [Invite]?)->()) {
        request(urlAddition: "projects/invites", method: .get, needsToken: true)
        { json, error in
            completion(nil, [])
            completion(error, Invite.map(json: json))
        }
    }
    
    class func invite(approve: Bool, invite: Invite, completion: @escaping (NSError?)->()) {
        let parameters: Parameters = [
            "inviteid": invite.id,
            "accept": approve ? 1 : 0
        ]
        
        request(urlAddition: "projects/invite", method: .post, parameters: parameters, needsToken: true)
        { json, error in
            completion(error)
        }
    }
    
    class func remove(manager: User, from project: Project, completion:@escaping (NSError?)->()) {
        guard let id = project.id else { return }
        
        let parameters: Parameters = [
            "managerid": manager.id,
            "projectid": id
        ]
        
        request(urlAddition: "projects/manager", method: .delete, parameters: parameters, needsToken: true)
        { json, error in
            completion(error)
        }
    }
    
    class func remove(client: User, from project: Project, completion:@escaping (NSError?)->()) {
        guard let id = project.id else { return }
        
        let parameters: Parameters = [
            "clientid": client.id,
            "projectid": id
        ]
        
        request(urlAddition: "projects/client", method: .delete, parameters: parameters, needsToken: true)
        { json, error in
            completion(error)
        }
    }
    
    class func remove(invite: Invite, completion:@escaping (NSError?)->()) {
        let parameters: Parameters = [
            "inviteid": invite.id,
            ]
        
        request(urlAddition: "projects/invite", method: .delete, parameters: parameters, needsToken: true)
        { json, error in
            completion(error)
        }
    }
    
    class func add(clients: [String], to project: Project, completion:@escaping (NSError?)->()) {
        guard let id = project.id else { return }
        
        let parameters: Parameters = [
            "projectid": id,
            "clients": clients
        ]
        
        request(urlAddition: "projects/clients", method: .post, parameters: parameters, needsToken: true)
        { json, error in
            completion(error)
        }
    }
    
    class func add(managers: [String], to project: Project, completion:@escaping (NSError?)->()) {
        guard let id = project.id else { return }
        
        let parameters: Parameters = [
            "projectid": id,
            "managers": managers
        ]
        
        request(urlAddition: "projects/managers", method: .post, parameters: parameters, needsToken: true)
        { json, error in
            completion(error)
        }
    }
    
    class func change(status: String, project: Project, completion:@escaping (NSError?, Post?)->()) {
        guard let id = project.id else { return }
        
        let parameters = [
            "projectid": id,
            "text": status,
            "type": "status"
        ]
        if isDemo() {
            completion(NSError(domain: NSLocalizedString("You can't do that in demo account", comment: "Error"), code: 500, userInfo: nil), nil)
            return
        }
        request(urlAddition: "posts", method: .post, parameters: parameters, needsToken: true)
        { json, error in
            completion(error, Post(json: json))
        }
    }
    
    class func edit(project: Project, progress:@escaping (Float)->(), completion:@escaping (NSError?, String?)->()) {
        if isDemo() {
            completion(NSError(domain: "You can't do that in demo account", code: 403, userInfo: nil), nil)
            return
        }
        
        var parameters: Parameters = [
            "projectid": project.id!,
            "title": project.title ?? "",
            "description": project.projectDescription ?? "",
            "progressEnabled": project.progressEnabled
        ]
        
        if let key = project.imageKey {
            parameters["image"] = key
        }
        
        if let image = project.tempImage {
            S3.upload(image: image, progress: progress)
            { key, error in
                if let error = error {
                    completion(NSError(domain: error, code: 500, userInfo: nil), nil)
                } else if let key = key {
                    parameters["image"] = key
                    request(urlAddition: "projects", method: .put, parameters: parameters, needsToken: true)
                    { json, error in
                        completion(error, key)
                    }
                }
            }
        } else {
            
            request(urlAddition: "projects", method: .put, parameters: parameters, needsToken: true)
            { json, error in
                completion(error, nil)
            }
        }
    }
    
    class func toggleFinished(for project: Project, completion: @escaping (NSError?)->()) {
        guard let id = project.id else {return }
        
        let parameters: Parameters = [
            "projectid": id
        ]
        
        if isDemo() {
            completion(NSError(domain: NSLocalizedString("You can't do that in demo account", comment: "Error"), code: 500, userInfo: nil))
            return
        }
        
        let urlAddition = project.isFinished ? "projects/revive" : "projects/finish"
        request(urlAddition: urlAddition, method: .post, parameters: parameters, needsToken: true)
        { json, error in
            completion(error)
        }
    }
    
    class func delete(project: Project, completion: @escaping (NSError?)->()) {
        guard let id = project.id else { return }
        
        if isDemo() {
            completion(NSError(domain: NSLocalizedString("You can't do that in demo account", comment: "Error"), code: 500, userInfo: nil))
            return
        }
        
        let parameters: Parameters = [
            "projectid": id
        ]
        
        request(urlAddition: "projects", method: .delete, parameters: parameters, needsToken: true)
        { json, error in
            completion(error)
        }
    }
    
    class func leave(project: Project, completion: @escaping (NSError?)->()) {
        guard let id = project.id else { return }
        let parameters: [String: String] = [
            "projectid": id
        ]
        
        if isDemo() {
            completion(NSError(domain: "You can't leave the demo project", code: 403, userInfo: nil))
            return
        }
        
        if project.isOwner {
            completion(NSError(domain: "You can't leave project as an owner", code: 403, userInfo: nil))
            return
        }
        
        
        request(urlAddition: "projects/leave", method: .post, parameters: parameters, needsToken: true)
        { json, error in
            completion(error)
        }
        
    }
}
