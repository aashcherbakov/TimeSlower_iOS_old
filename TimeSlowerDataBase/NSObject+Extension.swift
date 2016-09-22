//
//  NSObject+Extension.swift
//  TimeSlowerDataBase
//
//  Created by Oleksandr Shcherbakov on 9/1/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation

public extension NSObject {
    
    /// Class helper variable to return the name of the class without the namespace
    public class var className: String {
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
    
    /// Helper variable to return the name of the class without the namespace
    public var className: String {
        return NSStringFromClass(type(of: self)).components(separatedBy: ".").last!
    }
}
