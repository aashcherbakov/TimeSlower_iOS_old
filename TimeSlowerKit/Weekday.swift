//
//  Weekday.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 5/1/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

/**
 Enum that describes a weekday. Used to handle situations when in some contries
 first day is Sunday (US) while in others first day of week is Monday (Russia)
 */
public enum Weekday: Int {
    case first
    case second
    case third
    case forth
    case fifth
    case sixth
    case seventh
    
    public static var calendar = Calendar.current
    
    /**
     Created a weekday from NSDate instance
     
     - parameter date: NSDate
     
     - returns: Weekday
     */
    public static func createFromDate(_ date: Date) -> Weekday {
        let day = (calendar as NSCalendar).component(.weekday, from: date)
        return Weekday(rawValue: (day - 1) % 7)!
    }
    
    /// Short name of weekday retrived from NSDateFormatter method showrWeekdaySymbols
    public var shortName: String {
        let defaultDaysArray = StaticDateFormatter.shortDateNoTimeFromatter.shortWeekdaySymbols
        return defaultDaysArray![self.rawValue]
    }
    
    /// Checks if current day is a workday or not
    public var isWorkday: Bool {
        let range = (Weekday.calendar as NSCalendar).maximumRange(of: .weekday)
        
        if rawValue == range.location - 1 || rawValue == range.length - 1 {
            return false
        } else {
            return true
        }
    }
    
    /**
     Converts date to weekday and returns short name of the day
     
     - parameter date: NSDate of which we want to know name
     
     - returns: String with name
     */
    public static func shortDayNameForDate(_ date: Date) -> String {
        let weekday = Weekday.createFromDate(date)
        return weekday.shortName
    }
    
    /**
     Finds next closest day to a day. If there is no in current week, looks into next one.
     
     - parameter days:  array of Weekday instances
     - parameter toDay: Weekday to which comparison is made
     
     - returns: next closest day
     */
    public static func closestDay(_ days: [Weekday], toDay: Weekday) -> Weekday {
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
    
    /**
     Creates array of Weekdays for given basis
     
     - parameter basis: Basis instance
     
     - returns: Array of Weekdays
     */
    public static func weekdaysForBasis(_ basis: Basis) -> [Weekday] {
        var weekdays = [Weekday]()
        let defaultDaysArray: [Weekday] = daysForWeek(StaticDateFormatter.shortDateAndTimeFormatter)

        switch basis {
        case .daily, .random:
            weekdays = defaultDaysArray

        case .workdays, .weekends:
            let shouldBeWorkday = basis == .workdays
            for day in defaultDaysArray {
                if day.isWorkday == shouldBeWorkday {
                    weekdays.append(day)
                }
            }
        }

        return weekdays
    }
    
    // MARK: Private Functions

    /**
     Creates array of weekdays based given dateFormatter using shortWeekdaySymbols property.
     
     - parameter dateFormatter: NSDateFormatter
     
     - returns: array of Weekday instances
     */
    fileprivate static func daysForWeek(_ dateFormatter: DateFormatter) -> [Weekday] {
        var weekdays = [Weekday]()
        
        let dayNames = dateFormatter.shortWeekdaySymbols
        for weekday in dayNames! {
            guard let index = dayNames?.index(of: weekday) else {
                return weekdays
            }
            
            if let day = Weekday(rawValue: index) {
                weekdays.append(day)
            }
        }
        
        return weekdays
    }
}
