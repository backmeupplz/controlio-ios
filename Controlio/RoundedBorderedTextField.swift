//
//  RoundedBorderedTextField.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 09/03/16.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit

class RoundedBorderedTextField: UITextField {
    
    // MARK: - Variables -
    
    var borderWidth: CGFloat = 1
    var borderColor = UIColor(white: 1.0, alpha: 0.9)
    var cornerRadius: CGFloat = 5
    
    // MARK: - View Life Cycle -
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        roundCorners()
        addBorder()
        colorPlaceholder()
    }
    
    // MARK: - Private Functions -
    
    fileprivate func roundCorners() {
        layer.cornerRadius = cornerRadius
    }
    
    fileprivate func addBorder() {
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor.cgColor
    }
    
    fileprivate func colorPlaceholder() {
        attributedPlaceholder = NSAttributedString(string: placeholder!, attributes: [NSForegroundColorAttributeName:UIColor(white: 1.0, alpha: 0.5)])
    }
    
    // MARK: - General Functions -
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 10, dy: 10)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 10, dy: 10)
    }
}
