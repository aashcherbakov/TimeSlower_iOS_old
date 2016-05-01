//
//  TestHelpers.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 4/28/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation

struct TestHelper {
    
    static func tuesdayApril26() -> NSDate {
        let dateComponents = NSDateComponents()
        dateComponents.year = 2016
        dateComponents.day = 26
        dateComponents.month = 4
        return NSCalendar.currentCalendar().dateFromComponents(dateComponents)!
    }
    
    static func mondayApril25() -> NSDate {
        let dateComponents = NSDateComponents()
        dateComponents.year = 2016
        dateComponents.day = 25
        dateComponents.month = 4
        return NSCalendar.currentCalendar().dateFromComponents(dateComponents)!
    }
    
    static func sundayApril24() -> NSDate {
        let dateComponents = NSDateComponents()
        dateComponents.year = 2016
        dateComponents.day = 24
        dateComponents.month = 4
        return NSCalendar.currentCalendar().dateFromComponents(dateComponents)!
    }
    
    static func saturdayApril30() -> NSDate {
        let dateComponents = NSDateComponents()
        dateComponents.year = 2016
        dateComponents.day = 30
        dateComponents.month = 4
        return NSCalendar.currentCalendar().dateFromComponents(dateComponents)!
    }
}