//
//  ProjectDescriptionCell.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 18/05/15.
//  Copyright (c) 2015 Borodutch Studio LLC. All rights reserved.
//

import Foundation
import UIKit

class ProjectDescriptionCell: UITableViewCell {
    
    // MARK: - Public Variables -
    
    var object: ProjectObject! {
        didSet {
            setup()
        }
    }
    
    // MARK: - IBOutlets -
    
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    
    @IBOutlet weak var managerImageView: UIImageView!
    @IBOutlet weak var managerName: UILabel!
    @IBOutlet weak var managerPhoneButton: UIButton!
    @IBOutlet weak var managerEmailButton: UIButton!
    @IBOutlet weak var managerWebsiteButton: UIButton!
    
    // MARK: - IBActions -
    
    @IBAction func managerPhoneTouched(sender: UIButton) {
        //        UIApplication.sharedApplication().openURL(NSURL(string:"tel://\(sender.titleLabel!.text)")!);
        println("call: \(sender.titleLabel!.text!)")
    }
    
    @IBAction func managerEmailTouched(sender: UIButton) {
        println("email: \(sender.titleLabel!.text!)")
    }
    
    @IBAction func managerWebsiteTouched(sender: UIButton) {
        println("website: \(sender.titleLabel!.text!)")
    }
    
    // MARK: - General Methods -
    
    func setup() {
        if (object.lastImage != nil) {
            imageView(mainImageView, putURL: object.lastImage!)
            imageView(managerImageView, putURL: object.lastImage!)
        }
    }
    
    func imageView(imageView: UIImageView, putURL: NSURL) {
        imageView.alpha = CGFloat(0)
        imageView.sd_setImageWithURL(putURL, completed: { (image, error, type, url) -> Void in
            if (type != .Memory) {
                UIView.animateWithDuration(0.5, animations: { () -> Void in
                    imageView.alpha = CGFloat(1)
                })
            } else {
                imageView.alpha = CGFloat(1)
            }
        })
    }
}