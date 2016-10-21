//
//  FeatureList.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 20/10/2016.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit
import SwiftyJSON

class FeatureList: NSObject {
    
    // MARK: - Variables -
    
    static var payments = true
    
    // MARK: - Functions -
    
    class func fetchFeatureList() {
        Server.features
        { json, error in
            if let error = error {
                print(error.domain)
            } else if let json = json {
                deserialize(json: json)
            }
        }
    }
    
    class func deserialize(json: JSON) {
        payments = json["0"].bool ?? true
    }
}
