//
//  NewProjectCell.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 09/05/16.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit

protocol NewProjectCellDelegate: class {
    func editPhotoTouched()
    func chooseManagerTouched()
    func createTouched()
}

class NewProjectCell: UITableViewCell {
    
    // MARK: - Variables -
    
    var delegate: NewProjectCellDelegate?
    
    // MARK: - Outlets -
    
    @IBOutlet weak var projectImageView: CustomizableImageView!
    
    // MARK: - DEBUG -
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }
    
    @IBAction func createTouched(sender: AnyObject) {
//        let nikita = UIImage(named: "nikita")!

        projectImageView.s3Key = "574b8095fbdc05226baf382c/38540026-BE5C-4D5C-B896-2A29644CCCDA-2749-000004CC3331D0D6-1464754282.png"
//        S3.uploadImage(nikita,
//                       progress:
//            { progress in
//                        print(progress)
//        }) { url, error in
//            print(url ?? error)
//        }
    }
}
