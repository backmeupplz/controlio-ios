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
    
    // MARK: - Actions -
    
    @IBAction func addPhotoTouched(_ sender: AnyObject) {
        delegate?.editPhotoTouched()
    }
    
    @IBAction func chooseManagerTouched(_ sender: AnyObject) {
        delegate?.chooseManagerTouched()
    }
    
    @IBAction func createTouched(_ sender: AnyObject) {
        delegate?.createTouched()
    }
}
