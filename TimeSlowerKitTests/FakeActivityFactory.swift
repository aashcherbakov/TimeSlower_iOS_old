//
//  FakeActivityFactory.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 10/12/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation
@testable import TimeSlowerKit

public struct FakeActivityFactory {
    
    static let shortTimeFormatter = StaticDateFormatter.shortDateAndTimeFormatter

    
    static func fakeEndurance() -> Endurance {
        return Endurance(value: 30, period: .minutes)
    }
    
    static func fakeStats() -> Stats {
        return Stats(hours: 0, days: 0, months: 0, years: 0)
    }
    
    static func tenThirtyAM() -> Date {
        return shortTimeFormatter.date(from: "8/10/2016, 10:30 AM")!
    }
    
    static func elevenTenAM() -> Date {
        return shortTimeFormatter.date(from: "8/10/2016, 11:10 AM")!
    }

    
    func fakeActivity(
        name: String = "Morning shower",
        days: [Weekday] = [.first, .second, .third],
        timing: Timing = FakeActivityFactory.fakeTiming()) -> Activity {
        
        return Activity(withLifetimeDays: 18105, name: name, type: .routine, days: days, timing: timing, notifications: false)
    }
    
    func fakeActivity(startTime: Date) -> Activity {
        let timing = fakeTiming(startTime: startTime)
        let days = Weekday.weekdaysForBasis(.daily)
        return fakeActivity(days: days, timing: timing)
    }
    
    func fakeTiming(
        duration: Endurance = FakeActivityFactory.fakeEndurance(),
        startTime: Date = FakeActivityFactory.tenThirtyAM(),
        timeToSave: Int = 10,
        manuallyStarted: Date? = nil) -> Timing {
        
        return Timing(withDuration: duration, startTime: startTime, timeToSave: Double(timeToSave), alarmTime: startTime, manuallyStarted: manuallyStarted)
    }
    
    // Basic
    
    static func fakeTiming() -> Timing {
        return Timing(
            withDuration: FakeActivityFactory.fakeEndurance(),
            startTime: FakeActivityFactory.tenThirtyAM(),
            timeToSave: 10,
            alarmTime: NSDate() as Date,
            manuallyStarted: nil)
    }
    
    
    /// Returns activity
    /// - name:         "Morning shower"
    /// - days:         [.first, .second, .third]
    /// - startTime:    "8/10/2016, 10:30 AM"
    /// - duration:     40 minutes
    /// - timeToSave:   10 minutes
    ///
    /// - returns: Activity
    func fakeActivity() -> Activity {
        return Activity(withLifetimeDays: 18105,
                        name: "Morning shower",
                        type: .routine,
                        days: [.first, .second, .third],
                        timing: FakeActivityFactory.fakeTiming(),
                        notifications: false)
    }
    
}
