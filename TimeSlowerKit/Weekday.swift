//
//  Weekday.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 5/1/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation

/*
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
    
    /// Short name of weekday retrived from NSDateFormatter method showrWeekdaySymbols
    public var shortName: String {
        let defaultDaysArray = DateManager.sharedFormatter().shortWeekdaySymbols
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
        let defaultDaysArray: [Weekday] = daysForWeek(DateManager.sharedFormatter())
        
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
}