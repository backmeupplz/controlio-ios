//
//  S3.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 29/05/16.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit
import AWSS3

let S3BucketName = "controlio"
let cognitoPoolID = "us-east-1:16327515-a666-4f4b-b7b9-d7c831b285c0"
let region = AWSRegionType.usEast1

class S3: NSObject {
    
    // MARK: - Class fucntions -
    
    class func setup() {
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType:region,
                                                                identityPoolId:cognitoPoolID)
        let configuration = AWSServiceConfiguration(region:region, credentialsProvider:credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
    }
    
    class func getImage(_ key: String, completion:@escaping (UIImage?, String?)->()) {
        var completionHandler: AWSS3TransferUtilityDownloadCompletionHandlerBlock?
        
        let expression = AWSS3TransferUtilityDownloadExpression()
        expression.downloadProgress = {(task: AWSS3TransferUtilityTask, bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) in
            DispatchQueue.main.async {
                let progress = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
                NSLog("Progress is: %f",progress)
            }
        }
        
        completionHandler = { task, location, data, error in
            DispatchQueue.main.async(execute: {
                if let error = error {
                    completion(nil, error.localizedDescription)
                } else {
                    let image = UIImage(data: data!)
                    completion(image, nil)
                }
            })
        }
        
        let transferUtility = AWSS3TransferUtility.default()
        
        transferUtility.downloadData(fromBucket: S3BucketName,
                                     key: key,
                                     expression: expression,
                                     completionHander: completionHandler)
        .continue ({ task -> AnyObject? in
            if let error = task.error {
                completion(nil, error.localizedDescription)
            } else if let exception = task.exception {
                completion(nil, exception.name.rawValue)
            }
            return nil
        })
    }
    
    class func uploadImage(_ image: UIImage,
                           progress: @escaping (_ progress: Float)->(),
                           completion:@escaping (_ key: String?, _ error: String?)->()) {
        let path = saveImage(image)
        if path == nil {
            completion(nil, "Could not save image to file system")
            return
        }
        
        let ext = "png"
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest?.body = URL(fileURLWithPath: path!)
        uploadRequest?.key = "\(Server.userId ?? "no_userId")/" + ProcessInfo.processInfo.globallyUniqueString + "-\(Int(Date().timeIntervalSince1970))" + "." + ext
        uploadRequest?.bucket = S3BucketName
        uploadRequest?.uploadProgress = { bytesSent, totalBytesSent, totalBytesExpectedToSend in
            progress(Float(totalBytesSent) / Float(totalBytesExpectedToSend))
        }
        
        let transferManager = AWSS3TransferManager.default()
        transferManager?.upload(uploadRequest).continue({ (task) -> AnyObject! in
            if let error = task.error {
                completion(nil,
                           error.localizedDescription)
            } else if let exception = task.exception {
                
                completion(nil,
                           exception.name.rawValue)
            } else if task.result != nil {
                // Success
                completion(uploadRequest!.key!, nil)
            } else {
                completion(nil, "Unexpected empty result")
            }
            
            // Remove file
            let fileManager = FileManager.default
            do {
                try fileManager.removeItem(atPath: path!)
            }
            catch let error as NSError {
                print("File not deelted: \(error)")
            }
            return nil
        })
    }

    // MARK: - Private class functions -
    
    fileprivate class func saveImage(_ image: UIImage) -> String? {
        guard let data = UIImagePNGRepresentation(image)
                else { return nil }
        let timestamp = Int(Date().timeIntervalSince1970)
        let filename = getDocumentsDirectory().appendingPathComponent("\(timestamp).png")
        
        try? data.write(to: URL(fileURLWithPath: filename), options: [.atomic])
        return filename
    }
    
    fileprivate class func getDocumentsDirectory() -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory as NSString
    }
}
