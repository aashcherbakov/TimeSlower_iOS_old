//
//  Basis.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 8/7/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation

/**
 Enum that describes frequancy of activity repitition. 
 Basis is used purely for description, it should NOT be used in any calculations.
 
 - Daily:    daily
 - Workdays: monday-friday
 - Weekends: saturday and sunday
 - Random:   random days
 */
public enum Basis: Int {
    case Daily
    case Workdays
    case Weekends
    case Random
    
    public func description() -> String {
        switch self {
        case .Daily: return "Every single day"
        case .Workdays: return "Monday - Friday"
        case .Weekends: return "Saturday and Sunday"
        case .Random: return "Random days"
        }
    }
    
    /// Number of days basis ocupies in a week. Used to convert days to basis and vise versa
    public var numberOfDaysInWeek: Int {
        switch self {
        case .Daily: return 7
        case .Workdays: return 5
        case .Weekends: return 2
        case .Random: return 0
        }
    }
    
    /**
     Converts array of integers into Basis
     
     - parameter days: array of integers
     
     - returns: Basis instance
     */
    public static func basisFromDays(days: [Int]) -> Basis {
        return basisFromWeekdays(days.map({ (day) -> Weekday in
            guard let weekday = Weekday(rawValue: day) else {
                fatalError("Could not convert day's number representetion to weekday")
            }
            return weekday
        }))
    }
    
    /**
     Converts basis into array of Int.
     
     - parameter basis: Basis instance
     
     - returns: [Int]
     */
    public static func daysFromBasis(basis: Basis) -> [Int] {
        let weekdays = Weekday.weekdaysForBasis(basis)
        return weekdays.map({ (weekday) -> Int in
            return weekday.rawValue
        })
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