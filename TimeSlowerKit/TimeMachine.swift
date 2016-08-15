//
//  TimeMachine.swift
//  TimeSlower2
//
//  Created by Aleksander Shcherbakov on 7/13/15.
//  Copyright (c) 2015 1lastDay. All rights reserved.
//

import Foundation

/**
 *  Struct that helps with date manipulation and calculations
 */
public struct TimeMachine {
    
    private let dateFormatter = StaticDateFormatter.self
    
    public init() { }
    
    // rename to PastPeriod
    public enum Period: Int {
        case Today
        case LastMonth
        case LastYear
        case Lifetime
        
        public func stringForPeriod(period: Period) -> String {
            switch period {
            case .Today: return "Today"
            case .LastMonth: return "Last month"
            case .LastYear: return "Last year"
            case .Lifetime: return "Lifetime"
            }
        }
    }
    
    public func nextOccuranceOfWeekday(weekday: Weekday, fromDate date: NSDate) -> NSDate {
        let fromWeekday = Weekday.createFromDate(date)
        let difference = intervalFromDay(fromWeekday.rawValue, toDay: weekday.rawValue)
        let timeIntervalToAdd = difference * kSecondsInDay
        return NSDate(timeInterval: timeIntervalToAdd, sinceDate: date)
    }
    
    /// Returns string from array ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    public func correctWeekdayFromDate(date: NSDate) -> String {
        let weekday = Weekday.createFromDate(date)
        return weekday.shortName
    }
    
    public func shortDayNameForDate(date: NSDate) -> String {
        let weekday = Weekday.createFromDate(date)
        return weekday.shortName
    }
    
    public func startDateForPeriod(period: Period, sinceDate date: NSDate) -> NSDate {
        let componentsFromToday = NSCalendar.currentCalendar().components([.Year, .Month, .Day, .Hour, .Minute], fromDate: date)
        switch period {
        case .Today: break
        case .LastMonth: componentsFromToday.month = componentsFromToday.month - 1
        case .LastYear: componentsFromToday.year = componentsFromToday.year - 1
        case .Lifetime: break
        }
        
        return NSCalendar.currentCalendar().dateFromComponents(componentsFromToday)!
    }
    
    // refactor direct call to Profile
    public func numberOfDaysInPeriod(period: Period, fromDate date: NSDate) -> Int {
        let startDate = startDateForPeriod(period, sinceDate: date)
        let components = NSCalendar.currentCalendar().components(NSCalendarUnit.Day, fromDate: date, toDate: startDate, options: [])
        return (period == .Lifetime) ? Profile.fetchProfile()!.numberOfDaysTillEndOfLifeSinceDate(date) : abs(components.day)
    }
    
    public func numberOfWeekdaysInPeriod(period: Period, fromDate date: NSDate) -> Int {
        let startDate = startDateForPeriod(period, sinceDate: date)
        let endDate = endDateForPeriod(period, sinceDate: date)
        let components = NSCalendar.currentCalendar().components(.Day, fromDate: startDate, toDate: endDate, options: [])
        return components.day
    }
    
    public func endDateForPeriod(period: Period, sinceDate date: NSDate) -> NSDate {
        switch period {
        case .Today:
            return date
        case .LastMonth:
            return NSDate(timeInterval: -60*60*24*30, sinceDate: date)
        case .LastYear:
            let components = NSCalendar.currentCalendar().components([.Hour, .Minute, .Second, .Day, .Month, .Year], fromDate: date)
            components.year -= 1
            return NSCalendar.currentCalendar().dateFromComponents(components)!
        case .Lifetime:
            // TODO: UGLYNESS! remove to hell when it's clear what the fuck is this for anyway.
            return CoreDataStack.sharedInstance.fetchProfile()!.dateOfApproximateLifeEnd()
        }
    }
    
    // MARK: - Private Methods
    
    private func intervalFromDay(fromDay: Int, toDay: Int) -> Double {
        var difference: Double
        
        if toDay < fromDay {
            difference = Double(kNumberOfDaysInWeek - fromDay) + Double(toDay)
        } else {
            difference = Double(toDay - fromDay)
        }
        
        if difference == 0 {
            difference = Double(kNumberOfDaysInWeek)
        }
        
        return difference
    }
}