//
//  StatusCell.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 19/05/15.
//  Copyright (c) 2015 Borodutch Studio LLC. All rights reserved.
//

import Foundation
import UIKit
import Masonry

class StatusCell: UITableViewCell {
    
    // MARK: - IBOutlets -
    
    @IBOutlet weak var managerImageView: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var borderedView: UIView!
    
    // MARK: - Public Variables -
    
    var manager: ManagerObject!
    var object: StatusObject! {
        didSet {
            configure()
        }
    }
    
    // MARK: - General Methods -
    
    func configure() {
        if (object.type == StatusType.Status || object.type == StatusType.StatusWithImage) {
            managerImageView.loadURL(manager.image)
        }
        if (object.type == StatusType.StatusWithImage) {
            setupImages()
        }
        statusLabel.text = object.text
    }
    
    func setupImages() {
        var prevView = borderedView
        var attachements = object.attachements as [NSURL]!
        
        self.managerImageView.backgroundColor = UIColor.redColor()
        
        for index in 0...attachements.count-1 {
            if (index > 8) {
                break
            }
            var imageView = UIImageView()
            imageView.contentMode = UIViewContentMode.ScaleAspectFill
            imageView.backgroundColor = UIColor.redColor()
            imageView.cornerRadius = 6.0
            var attachment = attachements[index] as NSURL
            
            // Setup image
            imageView.loadURL(attachment)
            
            self.borderedView.addSubview(imageView)
            
            // Height (equal to width)
            imageView.mas_makeConstraints{make in
                make.height.equalTo()(imageView.mas_width)
            }
            
            // Width (equal for every view)
            if (index != 0) {
                imageView.mas_makeConstraints{ make in
                    make.width.equalTo()(prevView.mas_width)
                }
            }
            
            // Last image bottom space
            if (index == attachements.count-1 || index == 8) {
                imageView.mas_makeConstraints{ make in
                    make.bottom.equalTo()(self.borderedView.mas_bottom).offset()(-16)
                }
            }
            
            // X and Y coordinates + (offsets)
            switch index {
            case 0:
                imageView.mas_makeConstraints{ make in
                    make.left.equalTo()(self.statusLabel.mas_left)
                    make.top.equalTo()(self.statusLabel.mas_bottom).offset()(16)
                    if (attachements.count == 1) {
                        make.right.equalTo()(self.borderedView.mas_right).offset()(-16)
                    }
                }
            case 1, 4, 7:
                imageView.mas_makeConstraints{ make in
                    make.left.equalTo()(prevView.mas_right).offset()(8)
                    make.top.equalTo()(prevView.mas_top)
                    if (attachements.count == 2 && index == 1) {
                        make.right.equalTo()(self.borderedView.mas_right).offset()(-16)
                    }
                }
            case 2, 5, 8:
                imageView.mas_makeConstraints{ make in
                    make.left.equalTo()(prevView.mas_right).offset()(8)
                    make.top.equalTo()(prevView.mas_top)
                    make.right.equalTo()(self.borderedView.mas_right).offset()(-16)
                }
            case 3, 6:
                imageView.mas_makeConstraints{ make in
                    make.left.equalTo()(self.statusLabel.mas_left)
                    make.top.equalTo()(prevView.mas_bottom).offset()(8)
                }
            default:
                break
            }
            
            if (attachements.count > 9 && index == 8) {
                addPlusLabelToView(imageView)
            }
            
            // Set previous view
            prevView = imageView
        }
    }
    
    func addPlusLabelToView(view: UIView) {
        var label = UILabel()
        self.borderedView.addSubview(label)
        label.backgroundColor = UIColor(white: 0.0, alpha: 0.75)
        label.textColor = UIColor.whiteColor()
        label.text = "+\(object.attachements!.count-9)"
        label.mas_makeConstraints{ make in
            make.edges.equalTo()(view)
        }
        label.textAlignment = NSTextAlignment.Center
        label.layer.cornerRadius = 6.0
        label.layer.masksToBounds = true
    }
}