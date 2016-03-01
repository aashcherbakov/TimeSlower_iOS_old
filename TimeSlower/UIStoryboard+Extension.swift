//
//  UIStoryboard+Extension.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 2/28/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation

extension UIStoryboard {
    
    class func menuViewController() -> MenuVC? {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("MenuViewController") as? MenuVC
    }
    
    class func mainScreenVC() -> MainScreenVC? {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("MainScreenVC") as? MainScreenVC
    }
}