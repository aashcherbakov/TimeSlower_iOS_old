//
//  TimeMachine.swift
//  TimeSlower2
//
//  Created by Alexander Shcherbakov on 7/13/15.
//  Copyright (c) 2015 1lastDay. All rights reserved.
//

import Foundation

/**
 *  Struct that helps with date manipulation and calculations
 */
public struct TimeMachine {
    
    fileprivate let dateFormatter = StaticDateFormatter.self
    fileprivate let calendar: Calendar
    
    /**
     Initializer
     
     - parameter calendar: Set to NSCalendar.currentCalendar() by default
     
     - returns: calendar used for calculations
     */
    public init(calendar: Calendar = Calendar.current) {
        self.calendar = calendar
    }
    
    /**
     Finds a date of next specified weekday closest to given date.
     
     - parameter weekday: Weekday we are looking for
     - parameter date:    NSDate from which count starts.
     
     - returns: NSDate for next occurrence of given weekday
     */
    public func nextOccurrenceOfWeekday(_ weekday: Weekday, fromDate date: Date) -> Date {
        let fromWeekday = Weekday.createFromDate(date)
        let difference = intervalFromDay(fromWeekday.rawValue, toDay: weekday.rawValue)
        let timeIntervalToAdd = difference * kSecondsInDay
        return Date(timeInterval: timeIntervalToAdd, since: date)
    }
    
    /**
     Method to retrieve an NSDate in a past for specified period
     
     - parameter period: period in the past
     - parameter date:   starting date
     
     - returns: NSDate N days before given date
     */
    public func startDateForPeriod(_ period: PastPeriod, sinceDate date: Date) -> Date {
        var componentsFromToday = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        
        switch period {
        case .today: break
        case .lastMonth: componentsFromToday.month = componentsFromToday.month! - 1
        case .lastYear: componentsFromToday.year = componentsFromToday.year! - 1
        }
        
        return calendar.date(from: componentsFromToday)!
    }
    
    /**
     Returns number of days in given period since passed date
     
     - parameter period: period in the past
     - parameter date:   starting date
     
     - returns: Int with number of days
     */
    public func numberOfDaysInPeriod(_ period: PastPeriod, fromDate date: Date) -> Int {
        let startDate = startDateForPeriod(period, sinceDate: date)
        let components = calendar.dateComponents([.day], from: date, to: startDate)
        return abs(components.day!)
    }
    
    /**
     Combines hours and minutes of passed time with year/day/month of forDate
     
     - parameter time:    NSDate that contains wished time
     - parameter forDate: NSDate you want to transfer time to
     
     - returns: NSDate with passed time.
     */
    public func updatedTime(_ time: Date, forDate: Date) -> Date {
        let oldDateComponents = calendar.dateComponents([.hour, .minute], from: time)
        var newDateComponents = calendar.dateComponents([.month, .day, .year], from: forDate)
        
        newDateComponents.hour = oldDateComponents.hour
        newDateComponents.minute = oldDateComponents.minute
        
        return calendar.date(from: newDateComponents)!
    }
    
    /**
     Returns duration between dates in Minutes
     
     - parameter start:  NSDate for start date
     - parameter finish: NSDate for finish
     
     - returns: Double that represents number of minutes between given dates
     */
    public func minutesFromStart(_ start: Date, toFinish finish: Date) -> Double {
        let timeFromStartToFinish = start.timeIntervalSince(finish)
        return abs(timeFromStartToFinish) / 60
    }
    
    internal func intervalFromDay(_ fromDay: Int, toDay: Int) -> Double {
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
