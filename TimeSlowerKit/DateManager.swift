//
//  DateManager.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 5/1/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation

/// Class to operate with dates. Contains singleton for NSDateFormatter
public class DateManager: NSObject {
    private static let dateFormatter = NSDateFormatter()
    private static let shortFormatter = NSDateFormatter()
    
    /**
     Use singleton because date formatter creation is expensive
     
     - returns: NSDateFormatter instance setup with local time zone and current locale
     */
    public static func sharedFormatter() -> NSDateFormatter {
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        dateFormatter.locale = NSLocale.currentLocale()
        return dateFormatter
    }
    
    public static func sharedShortDateFormatter() -> NSDateFormatter {
        let formatter = shortFormatter
        formatter.timeZone = NSTimeZone.localTimeZone()
        formatter.locale = NSLocale.currentLocale()
        formatter.timeStyle = .ShortStyle
        formatter.dateStyle = .NoStyle
        return formatter
    }
    
    /**
     Returns short day name from given date
     
     - parameter date: NSDate instance
     
     - returns: String like "Mon", "Fri" etc
     */
    public static func shortDayNameForDate(date: NSDate) -> String {
        let dayNumber = NSCalendar.currentCalendar().component(.Weekday, fromDate: date)
        let defaultDaysArray = DateManager.sharedFormatter().shortWeekdaySymbols
        let weekDayNumber = ((dayNumber - 1) % 7)
        return defaultDaysArray[weekDayNumber]
    }
    
    /**
     Converts given array of weekdays into Basis case
     
     - parameter weekdays: Array of Weekday instances
     
     - returns: Basis case
     */
    public static func basisFromWeekdays(weekdays: [Weekday]) -> Basis {
        if shouldDays(weekdays, representBasis: .Weekends) {
            return .Weekends
        } else if shouldDays(weekdays, representBasis: .Workdays) {
            return .Workdays
        } else if weekdays.count == 7 {
            return .Daily
        } else {
            return .Random
        }
    }
    
    // MARK: - Private Functions
    
    private static func shouldDays(days: [Weekday], representBasis basis: Basis) -> Bool {
        guard days.count == basis.numberOfDaysInWeek else {
            return false
        }
        
        if basis == .Daily || basis == .Random {
            return true
        }
        
        let shouldBeWorkday = basis == .Workdays
        for day in days {
            if day.isWorkday != shouldBeWorkday {
                return false
            }
        }
        
        return true
    }
}