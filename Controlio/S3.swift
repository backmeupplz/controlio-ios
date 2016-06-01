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
let region = AWSRegionType.USEast1

class S3: NSObject {
    
    // MARK: - Class fucntions -
    
    class func setup() {
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType:region,
                                                                identityPoolId:cognitoPoolID)
        let configuration = AWSServiceConfiguration(region:region, credentialsProvider:credentialsProvider)
        AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = configuration
    }
    
    class func getImage(key: String, completion:(image: UIImage?, error: String?)->()) {
        var completionHandler: AWSS3TransferUtilityDownloadCompletionHandlerBlock?
        
        let expression = AWSS3TransferUtilityDownloadExpression()
        expression.downloadProgress = {(task: AWSS3TransferUtilityTask, bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) in
            dispatch_async(dispatch_get_main_queue(), {
                let progress = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
                NSLog("Progress is: %f",progress)
            })
        }
        
        completionHandler = { task, location, data, error in
            dispatch_async(dispatch_get_main_queue(), {
                if let error = error {
                    completion(image: nil, error: error.localizedDescription)
                } else {
                    let image = UIImage(data: data!)
                    completion(image: image, error: nil)
                }
            })
        }
        
        let transferUtility = AWSS3TransferUtility.defaultS3TransferUtility()
        
        transferUtility.downloadDataFromBucket(S3BucketName,
                                               key: key,
                                               expression: expression,
                                               completionHander: completionHandler)
        .continueWithBlock { task -> AnyObject? in
            if let error = task.error {
                completion(image: nil, error: error.localizedDescription)
            } else if let exception = task.exception {
                completion(image: nil, error: exception.name)
            }
            return nil
        }
    }
    
    class func uploadImage(image: UIImage,
                           progress: (progress: Float)->(),
                           completion:(key: String?, error: String?)->()) {
        let path = saveImage(image)
        if path == nil {
            completion(key: nil, error: "Could not save image to file system")
            return
        }
        
        let ext = "png"
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest.body = NSURL(fileURLWithPath: path!)
        uploadRequest.key = "\(Server.sharedManager.userId ?? "no_userId")/" + NSProcessInfo.processInfo().globallyUniqueString + "-\(Int(NSDate().timeIntervalSince1970))" + "." + ext
        uploadRequest.bucket = S3BucketName
        uploadRequest.uploadProgress = { bytesSent, totalBytesSent, totalBytesExpectedToSend in
            progress(progress: Float(totalBytesSent) / Float(totalBytesExpectedToSend))
        }
        
        let transferManager = AWSS3TransferManager.defaultS3TransferManager()
        transferManager.upload(uploadRequest).continueWithBlock { (task) -> AnyObject! in
            if let error = task.error {
                completion(key: nil,
                    error: error.localizedDescription)
            } else if let exception = task.exception {
                
                completion(key: nil,
                    error: exception.name)
            } else if task.result != nil {
                // Success
                completion(key: uploadRequest.key!, error: nil)
            } else {
                completion(key: nil, error: "Unexpected empty result")
            }
            
            // Remove file
            let fileManager = NSFileManager.defaultManager()
            do {
                try fileManager.removeItemAtPath(path!)
            }
            catch let error as NSError {
                print("File not deelted: \(error)")
            }
            return nil
        }
    }

    // MARK: - Private class functions -
    
    private class func saveImage(image: UIImage) -> String? {
        guard let data = UIImagePNGRepresentation(image)
                else { return nil }
        let timestamp = Int(NSDate().timeIntervalSince1970)
        let filename = getDocumentsDirectory().stringByAppendingPathComponent("\(timestamp).png")
        
        data.writeToFile(filename, atomically: true)
        return filename
    }
    
    private class func getDocumentsDirectory() -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
}
