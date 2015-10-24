//
//  NSObject+Extension.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 10/23/15.
//  Copyright © 2015 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation

// MARK: - NSObject extension to add helper methods
public extension NSObject{
    
    /// Class helper variable to return the name of the class without the namespace
    public class var className: String{
        return NSStringFromClass(self).componentsSeparatedByString(".").last!
    }
    
    /// Helper variable to return the name of the class without the namespace
    public var className: String{
        return NSStringFromClass(self.dynamicType).componentsSeparatedByString(".").last!
    }
}