//
//  TestHelpers.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 4/28/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation

@testable import TimeSlowerKit
@testable import TimeSlowerDataBase

struct TestHelper {
    
    var shortTimeFormatter = StaticDateFormatter.shortDateAndTimeFormatter
    var shortDateFormatter = StaticDateFormatter.shortDateNoTimeFromatter
    
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
    
    func tenThirtyAM() -> Date {
        return shortTimeFormatter.date(from: "8/10/2016, 10:30 AM")!
    }
    
    func elevenTenAM() -> Date {
        return shortTimeFormatter.date(from: "8/10/2016, 11:10 AM")!
    }
    
    func fakeActivity() -> Activity {
        return Activity(withLifetimeDays: 18105,
                        name: "Morning shower",
                        days: [.first, .second, .third], 
                        timing: fakeTiming(), 
                        notifications: false)
    }
    
    func fakeTiming() -> Timing {
        return Timing(
            withDuration: fakeEndurance(),
            startTime: tenThirtyAM(),
            timeToSave: 10,
            alarmTime: NSDate() as Date,
            manuallyStarted: nil)
    }
    
    func fakeEndurance() -> Endurance {
        return Endurance(value: 30, period: .minutes)
    }
    
    func fakeStats() -> Estimates {
        return Estimates(hours: 0, days: 0, months: 0, years: 0)
    }
    
    /// Profile
    /// - name:     "Anonymous"
    /// - country:  "United States"
    /// - birthday: "3/28/1987"
    /// - gender:   .male
    /// - maxAge:   60
    /// - returns: Profile
    func fakeProfile() -> Profile {
        return Profile(
            name: "Anonymous",
            country: "United States",
            dateOfBirth: shortDateFormatter.date(from: "3/28/1987")!,
            gender: .male,
            maxAge: 60,
            photo: nil)
    }
}
