//
//  InputView.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 09/05/16.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit
import SnapKit

protocol InputViewDelegate: class {
    
}

class InputView: UIView {
    
    // MARK: - Variables -
    
    weak var delegate: InputViewDelegate?
    
    // MARK: - Class Functions -
    
    class func view(superview: UIView, delegate: InputViewDelegate? = nil) -> InputView {
        let result = NSBundle.mainBundle().loadNibNamed(String(InputView), owner: nil, options: [:]).last as! InputView
        result.delegate = delegate
        
        superview.addSubview(result)
        result.snp_makeConstraints { make in
            make.bottom.equalTo(superview).inset(49)
            make.left.equalTo(superview)
            make.right.equalTo(superview)
        }
        
        return result
    }

}
