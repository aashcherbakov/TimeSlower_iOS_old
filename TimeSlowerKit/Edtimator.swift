//
//  TimeCalculator.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 7/10/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation

/**
 *  Struct that allows you to find sums of minutes/days/months/years spent on current activity
 */
public struct Estimator {
    
    public init() { }
    
    fileprivate let standardWeekDaysNumber = 7.0
    
    /**
     Converts duration of single day activity to duration per day weekly.
     For example, 20 minutes every workday will be 14.2 minutes per day.
     
     - parameter originalDuration: Int for minutes
     - parameter busyDays:         Int for number of days activity accurs in a week
     
     - returns: Double for duration per day.
     */
    public func durationPerDay(_ originalDuration: Int, busyDays: Int) -> Double {
        return abs((Double(originalDuration) * Double(busyDays)) / standardWeekDaysNumber)
    }
    
    /**
     Converts duration of single day acivity into total number of hours it will take in given amount of days
     
     - parameter days:     Total number of days you want to multiply single duration
     - parameter duration: Duration in minutes
     - parameter busyDays: Int for number of days activity accurs in a week
     
     - returns: Double for amount of hours one will spend on activity in specified number of days
     */
    public func totalHours(inDays days: Int, duration: Int, busyDays: Int) -> Double {
        let dailyMinutes = durationPerDay(duration, busyDays: busyDays)
        return dailyMinutes * Double(days) / 60
    }

    /**
     Converts duration of single day acivity into total number of days it will take in given amount of days
     
     - parameter days:     Total number of days you want to multiply single duration
     - parameter duration: Duration in minutes
     - parameter busyDays: Int for number of days activity accurs in a week
     
     - returns: Double for amount of days one will spend on activity in specified number of days
     */
    public func totalDays(inDays days: Int, duration: Int, busyDays: Int) -> Double {
        return totalHours(inDays: days, duration: duration, busyDays: busyDays) / 24
    }
    
    /**
     Converts duration of single day acivity into total number of months it will take in given amount of days
     
     - parameter days:     Total number of days you want to multiply single duration
     - parameter duration: Duration in minutes
     - parameter busyDays: Int for number of days activity accurs in a week
     
     - returns: Double for amount of months one will spend on activity in specified number of days
     */
    public func totalMonths(inDays days: Int, duration: Int, busyDays: Int) -> Double {
        return totalDays(inDays: days, duration: duration, busyDays: busyDays) / 30
    }
    
    /**
     Converts duration of single day acivity into total number of years it will take in given amount of days
     
     - parameter days:     Total number of days you want to multiply single duration
     - parameter duration: Duration in minutes
     - parameter busyDays: Int for number of days activity accurs in a week
     
     - returns: Double for amount of years one will spend on activity in specified number of days
     */
    public func totalYears(inDays days: Int, duration: Int, busyDays: Int) -> Double {
        return totalMonths(inDays: days, duration: duration, busyDays: busyDays) / 12
    }
    
    
}
