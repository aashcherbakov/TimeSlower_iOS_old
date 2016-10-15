//
//  Stats.swift
//  TimeSlowerKit
//
//  Created by Oleksandr Shcherbakov on 9/4/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation

/**
 *  Struct that is holding prognosed time spending on current activity
 */
public struct Stats {
    
    public let summHours: Double
    public let summDays: Double
    public let summMonths: Double
    public let summYears: Double
    
    fileprivate let timeCalculator = TimeCalculator()
    
    /**
     Function calculates hours, days, months and years spent on activity by multiplying minutes, busy days and totalDays
     
     - parameter minutes:   Int for minutes spent on activity
     - parameter busyDays:  Int for number of days in week user spends on activity
     - parameter totalDays: Int for total days profile has left to live
     
     - returns: Stats instance
     */
    public init(withDuration minutes: Int, busyDays: Int, totalDays: Int) {
        summHours = timeCalculator.totalHours(inDays: totalDays, duration: minutes, busyDays: busyDays)
        summDays = timeCalculator.totalDays(inDays: totalDays, duration: minutes, busyDays: busyDays)
        summMonths = timeCalculator.totalMonths(inDays: totalDays, duration: minutes, busyDays: busyDays)
        summYears = timeCalculator.totalYears(inDays: totalDays, duration: minutes, busyDays: busyDays)
    }
    
    public init(hours: Double, days: Double, months: Double, years: Double) {
        summHours = hours
        summDays = days
        summMonths = months
        summYears = years
    }
}
