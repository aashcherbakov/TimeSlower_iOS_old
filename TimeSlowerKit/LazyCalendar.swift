//
//  LazyCalendar.swift
//  TimeSlower2
//
//  Created by Aleksander Shcherbakov on 7/13/15.
//  Copyright (c) 2015 1lastDay. All rights reserved.
//

import Foundation

public class LazyCalendar {
    
    public enum DayName: String {
        case Sunday = "Sun"
        case Monday = "Mon"
        case Tuesday = "Tue"
        case Wednesdey = "Wed"
        case Thursday = "Thu"
        case Friday = "Fri"
        case Saturday = "Sat"
    }
    
    public enum Period: Int {
        case Today
        case LastMonth
        case LastYear
        case Lifetime
    }
    
    public class func dayNameForDate(date: NSDate) -> DayName {
        let startingDayNameString = LazyCalendar.correctWeekdayFromDate(date)
        return DayName(rawValue: startingDayNameString)!
    }
    
    public class func stringForPeriod(period: Period) -> String {
        switch period {
        case .Today: return "Today"
        case .LastMonth: return "Last month"
        case .LastYear: return "Last year"
        case .Lifetime: return "Lifetime"
        }
    }
    
    public class func nextDayWithName(dayName: DayName, fromDate date: NSDate) -> NSDate {
        let referenceDate = LazyCalendar.correctWeekdayFromDate(date)
        let arrayOfDaynames = DayResults.standardDateFormatter().shortWeekdaySymbols as [String]
        
        let referenceDateIndex = arrayOfDaynames.indexOf(referenceDate)!
        let searchedDayNameIndex = arrayOfDaynames.indexOf(dayName.rawValue)!
        
        var difference: Double!
        if searchedDayNameIndex < referenceDateIndex {
            difference = Double(arrayOfDaynames.count - referenceDateIndex) + Double(searchedDayNameIndex)
        } else {
            difference = Double(searchedDayNameIndex - referenceDateIndex)
        }
        if difference == 0 {
            difference = 7
        }
        
        let timeIntervalToAdd: NSTimeInterval = difference * 60*60*24
        return NSDate(timeInterval: timeIntervalToAdd, sinceDate: date)
    }
    
    /// Returns string from array ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    public class func correctWeekdayFromDate(date: NSDate) -> String {
        let weekdayNames = DayResults.standardDateFormatter().shortWeekdaySymbols as [String]
        let currentDay = NSCalendar.currentCalendar().component(.Weekday, fromDate: date)
        let weekdayNumber = (currentDay - 1) % 7
        return weekdayNames[weekdayNumber]
    }
    
    public class func shortDayNameForDate(date: NSDate) -> String {
        let dateFormatter = DayResults.standardDateFormatter()
        let daySymbols = dateFormatter.shortWeekdaySymbols
        
        let weekday = NSCalendar.currentCalendar().component(.Weekday, fromDate: date)
        let weekdayNumberForArray = (weekday - 1) % 7
        let dayName: String = daySymbols[weekdayNumberForArray]
        
        return dayName
    }
    
    public class func startDateForPeriod(period: Period, sinceDate date: NSDate) -> NSDate {
        let componentsFromToday = NSCalendar.currentCalendar().components([.Year, .Month, .Day, .Hour, .Minute], fromDate: date)
        switch period {
        case .Today: break
        case .LastMonth: componentsFromToday.month = componentsFromToday.month - 1
        case .LastYear: componentsFromToday.year = componentsFromToday.year - 1
        case .Lifetime: break
        }
        return NSCalendar.currentCalendar().dateFromComponents(componentsFromToday)!
        
    }
    
    public class func numberOfDaysInPeriod(period: Period, fromDate date: NSDate) -> Int {
        let startDate = startDateForPeriod(period, sinceDate: date)
        let components = NSCalendar.currentCalendar().components(NSCalendarUnit.Day, fromDate: date, toDate: startDate, options: [])
        return (period == .Lifetime) ? Profile.fetchProfile()!.numberOfDaysTillEndOfLifeSinceDate(date) : abs(components.day)
    }
    
    public class func numberOfWeekdaysNamed(dayName: DayName, forPeriod: Period, sinceDate: NSDate) -> Int {
        var numberOfWeekdays = 0
        let startDate = LazyCalendar.startDateForPeriod(forPeriod, sinceDate: sinceDate)
        var lastDate = LazyCalendar.nextDayWithName(dayName, fromDate: startDate)
        
        while lastDate == lastDate.earlierDate(sinceDate) || lastDate.isEqualToDate(sinceDate) {
            numberOfWeekdays++
            lastDate = LazyCalendar.nextDayWithName(dayName, fromDate: lastDate)
        }
        return numberOfWeekdays
    }
    
}