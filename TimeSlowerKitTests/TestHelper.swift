//
//  TestHelpers.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 4/28/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation

import TimeSlowerKit
struct TestHelper {
    
    static func tuesdayApril26() -> Date {
        var dateComponents = DateComponents()
        dateComponents.year = 2016
        dateComponents.day = 26
        dateComponents.month = 4
        return Calendar.current.date(from: dateComponents)!
    }
    
    static func mondayApril25() -> Date {
        var dateComponents = DateComponents()
        dateComponents.year = 2016
        dateComponents.day = 25
        dateComponents.month = 4
        return Calendar.current.date(from: dateComponents)!
    }
    
    static func sundayApril24() -> Date {
        var dateComponents = DateComponents()
        dateComponents.year = 2016
        dateComponents.day = 24
        dateComponents.month = 4
        return Calendar.current.date(from: dateComponents)!
    }
    
    static func saturdayApril30() -> Date {
        var dateComponents = DateComponents()
        dateComponents.year = 2016
        dateComponents.day = 30
        dateComponents.month = 4
        return Calendar.current.date(from: dateComponents)!
    }
}
