//
//  DataManager.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 08/05/16.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit

class DataManager: NSObject {

    // MARK: - Singleton -
    
    static let sharedManager = DataManager()
    
    // MARK: - Internal Functions -
    
    func getProjects(completion: (projects: [Project]?)->()) {
        completion(projects: Project.testProjects())
    }
}
