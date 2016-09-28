//
//  Platform.swift
//  Controlio
//
//  Created by Nikita Kolmogorov on 27/09/2016.
//  Copyright © 2016 Nikita Kolmogorov. All rights reserved.
//

import Foundation

struct Platform {
    static var isSimulator: Bool {
        return TARGET_OS_SIMULATOR != 0
    }
}
