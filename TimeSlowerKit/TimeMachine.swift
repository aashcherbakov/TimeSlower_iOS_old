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
    private let calendar: NSCalendar
    
    /**
     Initializer
     
     - parameter calendar: Set to NSCalendar.currentCalendar() by default
     
     - returns: calendar used for calculations
     */
    public init(calendar: NSCalendar = NSCalendar.currentCalendar()) {
        self.calendar = calendar
    }
    
    /**
     Finds a date of next specified weekday closest to given date.
     
     - parameter weekday: Weekday we are looking for
     - parameter date:    NSDate from which count starts.
     
     - returns: NSDate for next occurance of given weekday
     */
    public func nextOccuranceOfWeekday(weekday: Weekday, fromDate date: NSDate) -> NSDate {
        let fromWeekday = Weekday.createFromDate(date)
        let difference = intervalFromDay(fromWeekday.rawValue, toDay: weekday.rawValue)
        let timeIntervalToAdd = difference * kSecondsInDay
        return NSDate(timeInterval: timeIntervalToAdd, sinceDate: date)
    }
    
    /**
     Method to retrieve an NSDate in a past for specified period
     
     - parameter period: period in the past
     - parameter date:   starting date
     
     - returns: NSDate N days before given date
     */
    public func startDateForPeriod(period: PastPeriod, sinceDate date: NSDate) -> NSDate {
        let componentsFromToday = calendar.components([.Year, .Month, .Day, .Hour, .Minute], fromDate: date)
        
        switch period {
        case .Today: break
        case .LastMonth: componentsFromToday.month = componentsFromToday.month - 1
        case .LastYear: componentsFromToday.year = componentsFromToday.year - 1
        }
        
        return calendar.dateFromComponents(componentsFromToday)!
    }
    
    /**
     Returns number of days in given period since passed date
     
     - parameter period: period in the past
     - parameter date:   starting date
     
     - returns: Int with number of days
     */
    public func numberOfDaysInPeriod(period: PastPeriod, fromDate date: NSDate) -> Int {
        let startDate = startDateForPeriod(period, sinceDate: date)
        let components = calendar.components(NSCalendarUnit.Day, fromDate: date, toDate: startDate, options: [])
        return abs(components.day)
    }
    
    /**
     Combines hours and minutes of passed time with year/day/month of forDate
     
     - parameter time:    NSDate that contains wished time
     - parameter forDate: NSDate you want to transfer time to
     
     - returns: NSDate with passed time.
     */
    public func updatedTime(time: NSDate, forDate: NSDate) -> NSDate {
        let oldDateComponents = NSCalendar.currentCalendar().components([.Hour, .Minute], fromDate: time)
        let newDateComponents = NSCalendar.currentCalendar().components([.Month, .Day, .Year], fromDate: forDate)
        
        newDateComponents.hour = oldDateComponents.hour
        newDateComponents.minute = oldDateComponents.minute
        
        return NSCalendar.currentCalendar().dateFromComponents(newDateComponents)!
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