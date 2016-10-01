//
//  ScreenHeight.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 10/1/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation

/**
 Enum that describes iPhone screen height for adaptive layout
 */
internal enum ScreenHight: CGFloat {
    case iPhone4 = 480
    case iPhone5 = 568
    case iPhone6 = 667
    case iPhone6Plus = 736
    
    init(screenHeight: CGFloat = UIScreen.main.bounds.height) {
        self = ScreenHight(rawValue: screenHeight)!
    }
}
