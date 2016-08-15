//
//  TimeCalculator.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 7/10/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation

public struct TimeCalculator {
    
    public init() { }
    
    private let standardWeekDaysNumber = 7.0
    
    public func durationPerDay(originalDuration: Int, busyDays: Int) -> Double {
        return (Double(originalDuration) * Double(busyDays)) / standardWeekDaysNumber
    }
    
    public func totalHours(inDays days: Int, duration: Int, busyDays: Int) -> Double {
        let dailyMinutes = durationPerDay(duration, busyDays: busyDays)
        return dailyMinutes * Double(days) / 60
    }

    
    public func totalDays(inDays days: Int, duration: Int, busyDays: Int) -> Double {
        return totalHours(inDays: days, duration: duration, busyDays: busyDays) / 24
    }
    
    
    public func totalMonths(inDays days: Int, duration: Int, busyDays: Int) -> Double {
        return totalDays(inDays: days, duration: duration, busyDays: busyDays) / 30
    }
    
    public func totalYears(inDays days: Int, duration: Int, busyDays: Int) -> Double {
        return totalMonths(inDays: days, duration: duration, busyDays: busyDays) / 12
    }
    
    
}