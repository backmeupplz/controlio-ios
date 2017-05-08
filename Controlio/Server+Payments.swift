//
//  Server+Payments.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 27/04/2017.
//  Copyright © 2017 Nikita Kolmogorov. All rights reserved.
//

import UIKit
import Alamofire

extension Server {
    class func stripeGetCustomer(completion: @escaping (DefaultDataResponse?, NSError?)->()) {
        let parameters: Parameters = [
            "customerid": currentUser?.stripeId ?? ""
        ]
        requestData(urlAddition: "payments/customer", method: .get, parameters: parameters, needsToken: true)
        { response, error in
            completion(response, error)
        }
    }
    
    class func stripeCustomerAttach(sourceId: String, completion: @escaping (NSError?)->()) {
        let parameters: [String: Any] = [
            "source": sourceId,
            "customerid": currentUser?.stripeId ?? ""
        ]
        request(urlAddition: "payments/customer/sources", method: .post, parameters: parameters, needsToken: true)
        { json, error in
            completion(error)
        }
    }
    
    class func stripeCustomerSelect(defaultSourceId: String, completion: @escaping (NSError?)->()) {
        let parameters: [String: Any] = [
            "source": defaultSourceId,
            "customerid": currentUser?.stripeId ?? ""
        ]
        request(urlAddition: "payments/customer/default_source", method: .post, parameters: parameters, needsToken: true)
        { json, error in
            completion(error)
        }
    }
    
    class func stripeCustomerChoose(plan: Plan, completion: @escaping (NSError?)->()) {
        let parameters: [String: Any] = [
            "planid": plan.rawValue,
        ]
        request(urlAddition: "payments/customer/subscription", method: .post, parameters: parameters, needsToken: true)
        { json, error in
            if let error = error {
                completion(error)
            } else {
                saveUser(json!)
                completion(nil)
            }
        }
    }
    
    class func stripeRedeemCoupon(coupon: String, completion: @escaping (NSError?)->()) {
        let parameters: [String: Any] = [
            "coupon": coupon,
            ]
        request(urlAddition: "payments/customer/coupon", method: .post, parameters: parameters, needsToken: true)
        { json, error in
            completion(error)
        }
    }
}
