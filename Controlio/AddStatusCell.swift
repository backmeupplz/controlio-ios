//
//  AddStatusCell.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 28/05/15.
//  Copyright (c) 2015 Borodutch Studio LLC. All rights reserved.
//

import Foundation
import UIKit

class AddStatusCell: UITableViewCell, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - Variables -
    
    var delegate: StatusesViewController?
    let imagePicker = UIImagePickerController()
    var object: ProjectObject!
    
    // MARK: - Outlets -
    
    @IBOutlet weak var textView: BorderedTextView!
    @IBOutlet weak var photoView: UIImageView?
    @IBOutlet weak var addPhotoButton: BorderedButton?
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    // MARK: - View Life Cycle -
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imagePicker.delegate = self
    }
    
    // MARK: - UIImagePickerControllerDelegate -
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        photoView!.image = image
        
        delegate!.dismissViewControllerAnimated(true, completion: { () -> Void in
            self.setStatusBarLight(true)
        })
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        setStatusBarLight(true)
        delegate!.dismissViewControllerAnimated(true, completion: { () -> Void in
            self.setStatusBarLight(true)
        })
    }
    
    // MARK: - Actions -
    
    @IBAction func addPhotoTouched(sender: UIView) {
        textView.resignFirstResponder()
        let alertController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        if (alertController.popoverPresentationController != nil) {
            alertController.popoverPresentationController!.sourceView = sender
            alertController.popoverPresentationController!.sourceRect = sender.frame
            alertController.popoverPresentationController!.permittedArrowDirections = .Any;
        }
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
            
        }
        alertController.addAction(cancelAction)
        
        let takePhotoAction: UIAlertAction = UIAlertAction(title: "Take photo", style: .Default) { action -> Void in
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = .Camera
            
            self.delegate!.presentViewController(self.imagePicker, animated: true, completion: nil)
        }
        alertController.addAction(takePhotoAction)
        
        let libraryAction: UIAlertAction = UIAlertAction(title: "Choose from library", style: .Default) { action -> Void in
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = .PhotoLibrary
            
            self.setStatusBarLight(false)
            self.delegate!.presentViewController(self.imagePicker, animated: true, completion: nil)
        }
        alertController.addAction(libraryAction)
        
        if (photoView?.image != nil) {
            let removeAction: UIAlertAction = UIAlertAction(title: "Remove photo", style: .Destructive) { action -> Void in
                self.photoView?.image = nil
            }
            alertController.addAction(removeAction)
        }
        
        alertController.popoverPresentationController?.sourceView = sender ;
        let controller = UIApplication.sharedApplication().delegate?.window??.rootViewController
        controller!.presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func sendTouched(sender: AnyObject) {
        showSpinner(true)
        if (reuseIdentifier == "AddPostCell") {
            ServerManager.sharedInstance.sendPost(object.identificator, image: photoView?.image, text: self.textView.text, completion: { (error) -> () in
                self.dismissAddStatusCell()
            })
        } else {
            ServerManager.sharedInstance.sendStatus(object.identificator, text: self.textView.text, completion: { (error) -> () in
                self.dismissAddStatusCell()
            })
        }
    }
    
    func dismissAddStatusCell() {
        self.textView.text = ""
        self.photoView?.image = nil
        delegate?.shouldDismissAddStatusCellDone()
        showSpinner(false)
    }
    
    func showSpinner(show: Bool) {
        
        spinner.hidden = !show
        sendButton.hidden = show
        cancelButton.hidden = show
    }
    
    @IBAction func cancelTouched(sender: AnyObject) {
        textView.resignFirstResponder()
        if (textView.text.characters.count > 0 || photoView?.image != nil) {
            let alertController: UIAlertController = UIAlertController(title: "Are you sure you want to cancel?", message: "You will loose the draft", preferredStyle: .Alert)
            
            let cancelAction: UIAlertAction = UIAlertAction(title: "Nope", style: .Cancel) { action -> Void in
                
            }
            alertController.addAction(cancelAction)
            
            let yesAction: UIAlertAction = UIAlertAction(title: "Yes", style: .Default) { action -> Void in
                self.textView.text = ""
                self.photoView?.image = nil
                self.delegate?.shouldDismissAddStatusCellCancel()
            }
            alertController.addAction(yesAction)
            alertController.popoverPresentationController?.sourceView = sender as? UIView
            self.delegate!.presentViewController(alertController, animated: true, completion: nil)
        } else {
            self.delegate?.shouldDismissAddStatusCellCancel()
        }
        
    }
    
    // MARK: - General Methods -
    
    func setStatusBarLight(light: Bool) {
        if (light) {
            UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
        } else {
            UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
        }
    }
}