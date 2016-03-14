//
//  ProjectCell.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 13/03/16.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import UIKit

class ProjectCell: UITableViewCell {
    
    @IBOutlet private weak var projectImageView: UIImageView!
    @IBOutlet private weak var managerImageView: UIImageView!
    
    override func awakeFromNib() {
        configure()
    }
    
    func configure() {
        projectImageView.loadURL(NSURL(string: "http://www.city-n.ru/upload/2016/02/22/374107.jpg"))
        managerImageView.loadURL(NSURL(string: "http://rostwes.ru/wp-content/uploads/2015/12/48z.jpg"))
    }
    
}
