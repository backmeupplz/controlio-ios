//
//  Alamofire+Log.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 11/05/2017.
//  Copyright © 2017 Nikita Kolmogorov. All rights reserved.
//

import UIKit
import Alamofire

extension Request {
    public func debugLog() -> Self {
        #if DEBUG
            debugPrint(self)
        #endif
        return self
    }
}
