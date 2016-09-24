//
//  AddManagerCell.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 23/09/2016.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit

class AddManagerCell: UITableViewCell, UITextFieldDelegate {
    
    // MARK: - Outlets -
    
    @IBOutlet weak var emailTextfield: UITextField!
    
    // MARK: - UITextFieldDelegate -
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}
