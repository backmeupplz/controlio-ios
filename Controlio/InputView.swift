//
//  InputView.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 09/05/16.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit
import SnapKit
import SlackTextViewController

protocol InputViewDelegate: class {
    func openPickerWithDelegate(_ delegate: PickerDelegate)
    func closeImagePicker()
}

class InputView: CustomizableView, AttachmentContainerViewDelegate {
    
    // MARK: - Variables -
    
    weak var delegate: InputViewDelegate?
    var shown = false
    
    // MARK: - Outlets -
    
    @IBOutlet fileprivate weak var textView: SLKTextView!
    @IBOutlet fileprivate weak var textViewHeight: NSLayoutConstraint!
    @IBOutlet fileprivate weak var attachmentContainerView: AttachmentContainerView!
    
    // MARK: - Class Functions -
    
    class func view(_ superview: UIView, vc: UIViewController, delegate: InputViewDelegate? = nil) -> InputView {
        let result = Bundle.main.loadNibNamed(String(describing: InputView()), owner: nil, options: [:])?.last as! InputView
        result.delegate = delegate
        
        superview.addSubview(result)
        result.snp.makeConstraints { make in
            make.top.equalTo(superview.snp.bottom)
            make.left.equalTo(superview)
            make.right.equalTo(superview)
        }
        result.alpha = 0.0
        result.layoutIfNeeded()
        
        result.textView.placeholder = "Type new message..."
        result.textView.placeholderColor = UIColor(red: 128.0/255.0, green: 128.0/255.0, blue: 128.0/255.0, alpha: 1.0)
        result.textView.maxNumberOfLines = 5
        
        result.attachmentContainerView.delegate = result
        
        return result
    }
    
    // MARK: - AttachmentContainerViewDelegate -
    
    func closeImagePicker() {
        delegate?.closeImagePicker()
    }
    
    // MARK: - Actions -
    
    @IBAction func attachmentTouched(_ sender: AnyObject) {
        delegate?.openPickerWithDelegate(attachmentContainerView)
    }
    
    // MARK: - View Life Cycle -
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        subscribeNotifications()
    }
    
    // MARK: - General Functions -
    
    func show() {
        shown = true
        self.snp.remakeConstraints { make in
            make.bottom.equalTo(self.superview!)
            make.left.equalTo(self.superview!)
            make.right.equalTo(self.superview!)
        }
        UIView.animate(withDuration: 0.3, animations: {
            self.layoutIfNeeded()
            self.alpha = 1.0
        }) 
    }

    func hide() {
        shown = false
        textView.resignFirstResponder()
        self.snp.remakeConstraints { make in
            make.top.equalTo(self.superview!.snp.bottom)
            make.left.equalTo(self.superview!)
            make.right.equalTo(self.superview!)
        }
        UIView.animate(withDuration: 0.3, animations: {
            self.layoutIfNeeded()
            self.alpha = 0.0
        }) 
    }
    
    func changeBottomSpacing(_ spacing: CGFloat) {
        self.snp.remakeConstraints { make in
            make.bottom.equalTo(self.superview!.snp.bottom).inset(spacing)
            make.left.equalTo(self.superview!)
            make.right.equalTo(self.superview!)
        }
    }
    
    // MARK: - Private Functions -
    
    fileprivate func subscribeNotifications() {
        NotificationCenter.default.addObserver(self,
                                                         selector: #selector(InputView.textViewChangedContentSize),
                                                         name: NSNotification.Name.SLKTextViewContentSizeDidChange,
                                                         object: nil)
    }
    
    fileprivate func unsubscribeNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc fileprivate func textViewChangedContentSize() {
        if !textView.isExpanding {
            textViewHeight.constant = textView.contentSize.height
            layoutIfNeeded()
        }
    }
}
