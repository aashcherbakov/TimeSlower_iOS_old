//
//  Estimates.swift
//  TimeSlowerKit
//
//  Created by Oleksandr Shcherbakov on 9/4/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation

/// Struct that is holding estimated time spending on current activity.
public struct Estimates {

    public let sumHours: Double
    public let sumDays: Double
    public let sumMonths: Double
    public let sumYears: Double
    
    private let estimator = Estimator()
    
    /**
     Function calculates hours, days, months and years spent on activity by multiplying minutes, busy days and totalDays
     
     - parameter minutes:   Int for minutes spent on activity
     - parameter busyDays:  Int for number of days in week user spends on activity
     - parameter totalDays: Int for total days profile has left to live
     
     - returns: Stats instance
     */
    public init(withDuration minutes: Int, busyDays: Int, totalDays: Int) {
        sumHours = estimator.totalHours(inDays: totalDays, duration: minutes, busyDays: busyDays)
        sumDays = estimator.totalDays(inDays: totalDays, duration: minutes, busyDays: busyDays)
        sumMonths = estimator.totalMonths(inDays: totalDays, duration: minutes, busyDays: busyDays)
        sumYears = estimator.totalYears(inDays: totalDays, duration: minutes, busyDays: busyDays)
    }
    
    public init(hours: Double, days: Double, months: Double, years: Double) {
        sumHours = hours
        sumDays = days
        sumMonths = months
        sumYears = years
    }
}
