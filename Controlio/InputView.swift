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
import CLTokenInputView

protocol InputViewDelegate: class {
    func openPicker(with delegate: PickerDelegate, sender: UIView)
    func closeImagePicker()
    func shouldAddPost(text: String, attachments: [Any])
    func shouldChangeStatus(text: String)
    func shouldEditClients(clients: [String])
    func shouldEditPost(post: Post, text: String, attachments: [Any])
}

class InputView: CustomizableView, AttachmentContainerViewDelegate, CLTokenInputViewDelegate {
    
    // MARK: - Variables -
    
    var project: Project!
    weak var delegate: InputViewDelegate?
    var shown = false
    
    var post: Post? {
        didSet {
            configureForEditting()
        }
    }
    
    // MARK: - Outlets -
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBOutlet weak var tokenView: CLTokenInputView!
    @IBOutlet fileprivate weak var textView: SLKTextView!
    @IBOutlet fileprivate weak var textViewHeight: NSLayoutConstraint!
    @IBOutlet fileprivate weak var attachmentContainerView: AttachmentContainerView!
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var clipImage: UIImageView!
    @IBOutlet weak var clipButton: RoundedShadowedButton!
    
    @IBOutlet weak var textViewBottom: NSLayoutConstraint!
    @IBOutlet weak var tokenViewBottom: NSLayoutConstraint!
    
    @IBOutlet weak var cancelButton: UIButton!
    
    // MARK: - Class Functions -
    
    class func view(_ superview: UIView, vc: UIViewController, delegate: InputViewDelegate? = nil, project: Project) -> InputView {
        let result = Bundle.main.loadNibNamed("InputView", owner: nil, options: [:])?.last as! InputView
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
        
        result.setupTokenInputView()
        for client in project.clients {
            result.tokenView.add(CLToken(displayText: client.email, context: nil))
        }
        result.project = project
        
        return result
    }
    
    // MARK: - AttachmentContainerViewDelegate -
    
    func closeImagePicker() {
        delegate?.closeImagePicker()
    }
    
    // MARK: - CLTokenInputViewDelegate -
    
    func tokenInputView(_ view: CLTokenInputView, didChangeText text: String?) {
        
    }
    
    func tokenInputView(_ view: CLTokenInputView, didAdd token: CLToken) {
        setNeedsLayout()
    }
    
    func tokenInputView(_ view: CLTokenInputView, didRemove token: CLToken) {
        setNeedsLayout()
    }
    
    func tokenInputViewDidEndEditing(_ view: CLTokenInputView) {
        view.accessoryView = nil
    }
    
    func tokenInputViewDidBeginEditing(_ view: CLTokenInputView) {
        view.accessoryView = contactAddButton()
    }
    
    func tokenInputViewShouldReturn(_ view: CLTokenInputView) -> Bool {
        addTokenTouched()
        return false
    }
    
    // MARK: - Actions -
    
    @IBAction func attachmentTouched(_ sender: AnyObject) {
        delegate?.openPicker(with: attachmentContainerView, sender: sender as! UIView)
    }
    
    @IBAction func sendTouched(_ sender: AnyObject) {
        textView.resignFirstResponder()
        if let post = post {
            delegate?.shouldEditPost(post: post, text: textView.text, attachments: attachmentContainerView.wrapperView.attachments)
            return
        }
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            let text = textView.text ?? ""
            let attachments = attachmentContainerView.wrapperView.attachments
            delegate?.shouldAddPost(text: text, attachments: attachments)
        case 1:
            let text = textView.text ?? ""
            delegate?.shouldChangeStatus(text: text)
        case 2:
            let emails = tokenView.allTokens.map { $0.displayText }
            delegate?.shouldEditClients(clients: emails)
        default:
            break
        }
    }
    
    @IBAction func cancelTouched(_ sender: AnyObject) {
        post = nil
    }
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        sendButton.setTitle(index == 0 ? "Send" : "Save", for: .normal)
        textView.placeholder = index == 0 ? "Type new message..." : "Type new status..."
        
        clipImage.isHidden = index != 0
        clipButton.isEnabled = index == 0
        textView.isHidden = index == 2
        tokenView.isHidden = index != 2
        textViewBottom.priority = index == 2 ? 500 : 750
        tokenViewBottom.priority = index == 2 ? 750 : 500
        if index == 2 {
            for token in tokenView.allTokens {
                tokenView.remove(token)
            }
            for client in project.clients {
                tokenView.add(CLToken(displayText: client.email, context: nil))
            }
        }
        
        setNeedsLayout()
    }
    
    // MARK: - View Life Cycle -
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        subscribeNotifications()
    }
    
    // MARK: - General Functions -
    
    func clean() {
        textView.text = ""
        attachmentContainerView.wrapperView.attachments = []
    }
    
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
    
    func addTokenTouched() {
        let text = tokenView.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) ?? ""
        if !text.isEmpty && text.isEmail {
            let token = CLToken(displayText: text, context: nil)
            tokenView.add(token)
        } else {
            PopupNotification.showNotification("Please provide a valid email")
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
    
    fileprivate func setupTokenInputView() {
        tokenView.tintColor = UIColor.controlioGreen()
        tokenView.placeholderText = "Client emails"
        tokenView.textField.font = UIFont(name: "SFUIText-Regular", size: 14)
    }
    
    fileprivate func contactAddButton() -> UIButton {
        let contactAddButton = UIButton(type: .contactAdd)
        contactAddButton.addTarget(self, action: #selector(NewProjectCell.addTokenTouched), for: .touchUpInside)
        return contactAddButton
    }
    
    fileprivate func configureForEditting() {
        if let post = post {
            segmentedControl.isHidden = true
            cancelButton.isHidden = false
            textView.text = post.text
            attachmentContainerView.wrapperView.attachments = post.attachments
        } else {
            segmentedControl.isHidden = false
            cancelButton.isHidden = true
            textView.text = ""
            attachmentContainerView.wrapperView.attachments = []
        }
    }
}
