//
//  Payments.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 18/10/2016.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit
import Stripe

class Payments: NSObject, STPBackendAPIAdapter {
    @objc func retrieveCustomer(_ completion: @escaping STPCustomerCompletionBlock) {
        Server.stripeGetCustomer
            { response, error in
                if let error = error {
                    completion(nil, error)
                } else {
                    let deserializer = STPCustomerDeserializer(data: response!.data!, urlResponse: response!.response, error: response!.error)
                    if let error = deserializer.error {
                        completion(nil, error)
                    } else if let customer = deserializer.customer {
                        completion(customer, nil)
                    } else {
                        completion(nil, NSError(domain: NSLocalizedString("Something went wrong", comment: "Payments error"), code: 500, userInfo: nil))
                    }
                }
        }
    }
    @objc func attachSource(toCustomer source: STPSource, completion: @escaping STPErrorBlock) {
        Server.stripeCustomerAttach(sourceId: source.stripeID)
        { error in
            completion(error)
        }
    }
    
    @objc func selectDefaultCustomerSource(_ source: STPSource, completion: @escaping STPErrorBlock) {
        Server.stripeCustomerSelect(defaultSourceId: source.stripeID)
        { error in
            completion(error)
        }
    }
}
