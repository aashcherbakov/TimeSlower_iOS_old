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
        case LastMonth
        case LastYear
        case Lifetime
    }
    
    public class func dayNameForDate(date: NSDate) -> DayName {
        let startingDayNameString = LazyCalendar.correctWeekdayFromDate(date)
        return DayName(rawValue: startingDayNameString)!
    }
    
    public class func nextDayWithName(dayName: DayName, fromDate date: NSDate) -> NSDate {
        let referenceDate = LazyCalendar.correctWeekdayFromDate(date)
        let arrayOfDaynames = DayResults.standardDateFormatter().shortWeekdaySymbols as! [String]
        
        let referenceDateIndex = find(arrayOfDaynames, referenceDate)!
        let searchedDayNameIndex = find(arrayOfDaynames, dayName.rawValue)!
        
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
        let weekdayNames = DayResults.standardDateFormatter().shortWeekdaySymbols as! [String]
        let currentDay = NSCalendar.currentCalendar().component(.CalendarUnitWeekday, fromDate: date)
        let weekdayNumber = (currentDay - 1) % 7
        return weekdayNames[weekdayNumber]
    }
    

    public class func startDateForPeriod(period: Period, sinceDate date: NSDate) -> NSDate {
        var componentsFromToday = NSCalendar.currentCalendar().components(.CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitDay | .CalendarUnitHour | .CalendarUnitMinute, fromDate: date)
        switch period {
        case .LastMonth: componentsFromToday.month = componentsFromToday.month - 1
        case .LastYear: componentsFromToday.year = componentsFromToday.year - 1
        case .Lifetime: break
        }
        return NSCalendar.currentCalendar().dateFromComponents(componentsFromToday)!
        
    }
    
    public class func numberOfDaysInPeriod(period: Period, fromDate date: NSDate) -> Int {
        let startDate = startDateForPeriod(period, sinceDate: date)
        let components = NSCalendar.currentCalendar().components(NSCalendarUnit.CalendarUnitDay, fromDate: date, toDate: startDate, options: nil)
        return (period == .Lifetime) ? Profile.fetchProfile()!.numberOfDaysTillEndOfLifeSinceDate(date) : abs(components.day)
    }
    
    public class func numberOfWeekdaysNamed(dayName: DayName, forPeriod: Period, sinceDate: NSDate) -> Int {
        var numberOfWeekdays = 0
        let startDate = LazyCalendar.startDateForPeriod(forPeriod, sinceDate: sinceDate)
        var lastDate = LazyCalendar.nextDayWithName(dayName, fromDate: startDate)
        
        while lastDate <= sinceDate {
            numberOfWeekdays++
            lastDate = LazyCalendar.nextDayWithName(dayName, fromDate: lastDate)
        }
        return numberOfWeekdays
    }
    
}