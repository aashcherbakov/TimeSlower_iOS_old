//
//  Weekday.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 5/1/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation

/**
 Enum that describes a weekday. Used to handle situations when in some contries
 first day is Sunday (US)
 while in others first day of week is Monday (Russia)
 */
public enum Weekday: Int {
    case First
    case Second
    case Third
    case Forth
    case Fifth
    case Sixth
    case Seventh
    
    /**
     Created a weekday from NSDate instance
     
     - parameter date: NSDate
     
     - returns: Weekday
     */
    public static func createFromDate(date: NSDate) -> Weekday {
        let day = NSCalendar.currentCalendar().component(.Weekday, fromDate: date)
        return Weekday(rawValue: (day - 1) % 7)!
    }
    
    /// Short name of weekday retrived from NSDateFormatter method showrWeekdaySymbols
    public var shortName: String {
        let defaultDaysArray = StaticDateFormatter.shortDateNoTimeFromatter.shortWeekdaySymbols
        return defaultDaysArray[self.rawValue]
    }
    
    /// Checks if current day is a workday or not
    public var isWorkday: Bool {
        let range = NSCalendar.currentCalendar().maximumRangeOfUnit(.Weekday)
        
        if rawValue == range.location - 1 || rawValue == range.length - 1 {
            return false
        } else {
            return true
        }
    }
    
    public static func weekdaysForBasis(basis: Basis) -> [Weekday] {
        var weekdays = [Weekday]()
        let defaultDaysArray: [Weekday] = daysForWeek(StaticDateFormatter.shortDateAndTimeFormatter)
        
        switch basis {
        case .Daily, .Random:
            weekdays = defaultDaysArray
            
        case .Workdays, .Weekends:
            let shouldBeWorkday = basis == .Workdays
            for day in defaultDaysArray {
                if day.isWorkday == shouldBeWorkday {
                    weekdays.append(day)
                }
            }
        }
        
        return weekdays
    }

    /**
     Creates array of weekdays based given dateFormatter using shortWeekdaySymbols property.
     
     - parameter dateFormatter: NSDateFormatter
     
     - returns: array of Weekday instances
     */
    private static func daysForWeek(dateFormatter: NSDateFormatter) -> [Weekday] {
        var weekdays = [Weekday]()
        
        let dayNames = dateFormatter.shortWeekdaySymbols
        for weekday in dayNames {
            guard let index = dayNames.indexOf(weekday) else {
                return weekdays
            }
            
            if let day = Weekday(rawValue: index) {
                weekdays.append(day)
            }
        }
        
        return weekdays
    }
    
    /**
     Converts Set of Days stored in Activity to array of Weekdays
     
     - parameter days: Set<Day>
     
     - returns: Array of Weeday instances
     */
    public static func weekdaysFromSetOfDays(days: Set<Day>) -> [Weekday] {
        var busyWeekdays = [Weekday]()
        
        for day in days {
            if let weekday = Weekday(rawValue: day.number.integerValue) {
                busyWeekdays.append(weekday)
            }
        }
        
        return busyWeekdays
    }
    

    
    
    /**
     Finds next closest day to a day. If there is no in current week, looks into next one.
     
     - parameter days:  array of Weekday instances
     - parameter toDay: Weekday to which comparison is made
     
     - returns: next closest day
     */
    public static func closestDay(days: [Weekday], toDay: Weekday) -> Weekday {
        guard days.count > 0 else {
            fatalError("Empty array passed as an argument")
        }
        
        var closestDay: Weekday?
        var closestDistance = kNumberOfDaysInWeek
        
        // step 1: find next in this week
        for day in days {
            let distance = day.rawValue - toDay.rawValue
            if distance > 0 && distance < closestDistance {
                closestDistance = distance
                closestDay = day
            }
        }
        
        // step 2: find next in next week
        if closestDay == nil {
            for day in days {
                let distance = day.rawValue - toDay.rawValue
                if distance < closestDistance {
                    closestDistance = distance
                    closestDay = day
                }
            }
        }
        
        if let closestDay = closestDay {
            return closestDay
        } else {
            fatalError("No weekdays in passed arrays")
        }
    }
    

}
