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
    case daily
    case workdays
    case weekends
    case random
    
    public func description() -> String {
        switch self {
        case .daily: return "Every single day"
        case .workdays: return "Monday - Friday"
        case .weekends: return "Saturday and Sunday"
        case .random: return "Random days"
        }
    }
    
    /// Number of days basis ocupies in a week. Used to convert days to basis and vise versa
    public var numberOfDaysInWeek: Int {
        switch self {
        case .daily: return 7
        case .workdays: return 5
        case .weekends: return 2
        case .random: return 0
        }
    }
    
    /**
     Converts array of integers into Basis
     
     - parameter days: array of integers
     
     - returns: Basis instance
     */
    public static func basisFromDays(_ days: [Int]) -> Basis {
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
    public static func daysFromBasis(_ basis: Basis) -> [Int] {
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
    public static func basisFromWeekdays(_ weekdays: [Weekday]) -> Basis {
        if shouldDays(weekdays, representBasis: .weekends) {
            return .weekends
        } else if shouldDays(weekdays, representBasis: .workdays) {
            return .workdays
        } else if weekdays.count == 7 {
            return .daily
        } else {
            return .random
        }
    }
    
    // MARK: - Private Functions
    
    fileprivate static func shouldDays(_ days: [Weekday], representBasis basis: Basis) -> Bool {
        guard days.count == basis.numberOfDaysInWeek else {
            return false
        }
        
        if basis == .daily || basis == .random {
            return true
        }
        
        let shouldBeWorkday = basis == .workdays
        for day in days {
            if day.isWorkday != shouldBeWorkday {
                return false
            }
        }
        
        return true
    }
}
