//
//  PushNoAnimationSegue.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 20/05/15.
//  Copyright (c) 2015 Borodutch Studio LLC. All rights reserved.
//

import Foundation
import UIKit

class PushNoAnimationSegue: UIStoryboardSegue {
    override func perform () {
        let src = self.sourceViewController as! UIViewController
        let dst = self.destinationViewController as!UIViewController
        src.navigationController!.pushViewController(dst, animated:false)
    }
    
}