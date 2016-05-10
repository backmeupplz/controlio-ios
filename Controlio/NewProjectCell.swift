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
    
}
