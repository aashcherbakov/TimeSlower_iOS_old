//
//  Float+Double+Extension.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 10/23/15.
//  Copyright © 2015 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation

extension Float {
    func format(f: String) -> String {
        return NSString(format: "%\(f)f", self) as String
    }
}

extension Double {
    func format(f: String) -> String {
        return NSString(format: "%\(f)f", self) as String
    }
}