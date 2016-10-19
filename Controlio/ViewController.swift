//
//  ViewController.swift
//  StripeExample
//
//  Created by Nikita Kolmogorov on 19/10/2016.
//  Copyright © 2016 Nikita Kologorov. All rights reserved.
//

import UIKit
import Alamofire
import Stripe
import SwiftyJSON

class ViewController: UIViewController {
    
    var paymentContext: STPPaymentContext!
    
    // MARK: - View Controller Life Cycle -

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureStripe()
        configurePaymentContext()
    }
    
    // MARK: - Outlets -

    @IBAction func showPaymentsTouched(_ sender: AnyObject) {
        paymentContext.presentPaymentMethodsViewController()
    }
    
    // MARK: - General functions -
    
    func configureStripe() {
        STPPaymentConfiguration.shared().publishableKey = "pk_test_QUk0bgtsbIfR67SVr0EHnIpx"
        STPPaymentConfiguration.shared().companyName = "Controlio"
    }
    
    func configurePaymentContext() {
        paymentContext = STPPaymentContext(apiAdapter: self)
        paymentContext.hostViewController = self
        paymentContext.delegate = self
    }
}

extension ViewController: STPPaymentContextDelegate {
    func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
        
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPErrorBlock) {
        
    }
    func paymentContext(_ paymentContext: STPPaymentContext, didFinishWith status: STPPaymentStatus, error: Error?) {
        
        print(error)
    }
    func paymentContext(_ paymentContext: STPPaymentContext, didFailToLoadWithError error: Error) {
        
        print(error)
        let _ = self.navigationController?.popViewController(animated: true)
    }
}

extension ViewController: STPBackendAPIAdapter {
    @objc func retrieveCustomer(_ completion: @escaping STPCustomerCompletionBlock) {
        stripeGetCustomer
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
                        completion(nil, NSError(domain: "Something went wrong", code: 500, userInfo: nil))
                    }
                }
        }
    }
    @objc func attachSource(toCustomer source: STPSource, completion: @escaping STPErrorBlock) {
        
        stripeCustomerAttach(sourceId: source.stripeID)
        { error in
            completion(error)
        }
    }
    
    @objc func selectDefaultCustomerSource(_ source: STPSource, completion: @escaping STPErrorBlock) {
        stripeCustomerSelect(defaultSourceId: source.stripeID)
        { error in
            completion(error)
        }
    }
}

extension ViewController {
    func stripeGetCustomer(completion: @escaping (DefaultDataResponse?, NSError?)->()) {
        let parameters: [String: Any] = [
            "customerid": "cus_9OtFLqdxYj04Fd"
        ]
        requestData(urlAddition: "payments/customer", method: .get, parameters: parameters, needsToken: true)
        { response, error in
            completion(response, error)
        }
    }
    
    func stripeCustomerAttach(sourceId: String, completion: @escaping (NSError?)->()) {
        let parameters: [String: Any] = [
            "source": sourceId,
            "customerid": "cus_9OtFLqdxYj04Fd"
        ]
        request(urlAddition: "payments/customer/sources", method: .post, parameters: parameters, needsToken: true)
        { json, error in
            completion(error)
        }
    }
    
    func stripeCustomerSelect(defaultSourceId: String, completion: @escaping (NSError?)->()) {
        let parameters: [String: Any] = [
            "source": defaultSourceId,
            "customerid": "cus_9OtFLqdxYj04Fd"
        ]
        request(urlAddition: "payments/customer/default_source", method: .post, parameters: parameters, needsToken: true)
        { json, error in
            completion(error)
        }
    }
}

extension ViewController {
    func request(urlAddition: String, method: HTTPMethod, parameters: [String:Any]? = nil, needsToken: Bool, completion: @escaping (JSON?, NSError?)->()) {
        Alamofire.request("https://api.controlio.co/" + urlAddition, method: method, parameters: parameters, encoding: method == .get ? URLEncoding.default : JSONEncoding.default, headers: headers())
            .responseJSON { response in
                if let errorString = response.result.error?.localizedDescription {
                    completion(nil, NSError(domain: errorString, code: 500, userInfo: nil))
                } else if let error = self.checkForErrors(json: JSON(response.result.value)) {
                    completion(nil, error)
                } else if response.response?.statusCode == 500 {
                    completion(nil, NSError(domain: NSLocalizedString("Server error", comment: "Error"), code: 500, userInfo: nil))
                } else {
                    completion(JSON(response.result.value), nil)
                }
        }
    }
    
    func requestData(urlAddition: String, method: HTTPMethod, parameters: [String:Any]? = nil, needsToken: Bool, completion: @escaping (DefaultDataResponse?, NSError?)->()) {
        Alamofire.request("https://api.controlio.co/" + urlAddition, method: method, parameters: parameters, encoding: method == .get ? URLEncoding.default : JSONEncoding.default, headers: headers())
            .response { response in
                if let errorString = response.error?.localizedDescription {
                    completion(nil, NSError(domain: errorString, code: 500, userInfo: nil))
                } else if let error = self.checkForErrors(json: JSON(response.data)) {
                    completion(nil, error)
                } else if response.response?.statusCode == 500 {
                    completion(nil, NSError(domain: NSLocalizedString("Server error", comment: "Error"), code: 500, userInfo: nil))
                } else {
                    completion(response, nil)
                }
        }
    }
    
    func checkForErrors(json: JSON) -> NSError? {
        if let error = json["errors"].array?.first {
            return NSError(domain: error["messages"].array?.first?.string ?? NSLocalizedString("Something went wrong", comment: "Error"), code: error["status"].int ?? 500, userInfo: nil)
        } else if let errorName = json["errors"].dictionary?.keys.first {
            return NSError(domain: json["errors"][errorName]["message"].string ?? NSLocalizedString("Something went wrong", comment: "Error"), code: 500, userInfo: nil)
        } else if let message = json["message"].string {
            return NSError(domain: message, code: json["status"].int ?? 500, userInfo: nil)
        } else {
            return nil
        }
    }
    
    func headers() -> [String:String] {
        return [
            "apiKey": "p[oqkix=%FAi]&FMAYnLUJJWC,w",
            "token": "eyJhbGciOiJIUzI1NiJ9.c3RyaXBlMTBAYm9yb2R1dGNoLmNvbQ.oVqYDTtJu6s8C0Eyx4OD6K1FZx5ephzZr2XhmSzGjJo",
            "userId": "580698eb7c8623d59b36b18c"
        ]
    }
}
