//
//  Activity.swift
//  TimeSlowerKit
//
//  Created by Oleksandr Shcherbakov on 9/3/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation

/// Activity
public struct Activity: Persistable {

    // MARK: - Persistable

    public let resourceId: String

    // MARK: - Activity

    public let name: String
    public let days: [Weekday]
    public let notifications: Bool
    public let estimates: Estimates
    public let stats: Stats

    // MARK: - Mutable properties

    fileprivate(set) public var results: Set<Result>
    fileprivate(set) public var timing: Timing

    // MARK: - Private properties

    private let timeMachine = TimeMachine()
    private let dateFormatter = StaticDateFormatter.shortDateNoTimeFromatter
    
    /// Marks activity as manually started - assigns manuallyStarted property to 
    /// timing object. Should be set to nil when activity is finished.
    ///
    /// - Parameter date: optional date.
    public mutating func setManuallyStarted(to date: Date?) {
        self.timing = timing.update(withManuallyStarted: date)
    }
    
    /// Assigns passed Set to results property.
    ///
    /// - Parameter results: Set of results.
    public mutating func update(with results: Set<Result>) {
        self.results = results
    }
    
    /// Assigns passed Timing object to timing property.
    ///
    /// - Parameter timing: Timing instance.
    public mutating func update(with timing: Timing) {
        self.timing = timing
    }
    
    public func lastWeekResults() -> [Result] {
        // TODO: find faster way to get last 7 results
        let sortedResults = results.sorted {
            $0.finishTime.compare($1.finishTime) == .orderedDescending
        }
        
        let firstSeven = Array(sortedResults.prefix(7))
        return firstSeven
    }
    
    public func isDone(forDate date: Date = Date()) -> Bool {
        let searchString = dateFormatter.string(from: date)
        let resultsForToday = results.filter { (result) -> Bool in
            return result.stringDate == searchString
        }
        
        return resultsForToday.count > 0
    }
    
    public func isGoingNow(date: Date = Date()) -> Bool {
        let startsBefore = startsEarlier(then: date)
        let endsAfter = endsLater(then: date)
        let notDoneYet = !isDone(forDate: date)
        return startsBefore && endsAfter && notDoneYet
    }
    
    public func isUnfinished(forDate date: Date = Date()) -> Bool {
        let started = timing.manuallyStarted != nil
        let pastDue = endsEarlier(then: date)
        return started && pastDue
    }
    
    /// Determins if activity takes place in given date.
    ///
    /// - Parameter date: current date by default.
    /// - Returns: True if days array contains passed date's weekday.
    public func happensIn(date: Date = Date()) -> Bool {
        let weekday = Weekday.createFromDate(date)
        let isOverdue = finishTime(inDate: date) < date
        return days.contains(weekday) && !isOverdue
    }
    
    public func nextActionTime(forDate date: Date = Date()) -> Date {
        if happensIn(date: date) && !isDone(forDate: date) {
            if isGoingNow(date: date) {
                return finishTime(inDate: date)
            } else {
                return startTime(inDate: date)
            }
        } else {
            return startTimeNextDay(from: date)
        }
    }
    
    /// Returns activity start time in given date (today by default)
    public func startTime(inDate date: Date = Date()) -> Date {
        return timing.starts(inDate: date)
    }

    /// Returns activity finish time in given date (today by default)
    public func finishTime(inDate date: Date = Date()) -> Date {
        return timing.finishes(inDate: date)
    }

    public func alarmTime(inDate date: Date = Date()) -> Date {
        return timing.alarm(inDate: date)
    }
    
    public func minutesToSave() -> Double {
        return Double(timing.timeToSave)
    }

    public func duration() -> Endurance {
        return timing.duration
    }
    
    /// Should only be used for copying object, not accessed directly
    ///
    /// - returns: Timing that is private property of Activity
    public func getTiming() -> Timing {
        return timing
    }
    
    /// Returns basis constructed of weekdays
    ///
    /// - returns: Basis instance
    public func basis() -> Basis {
        return Basis.basisFromWeekdays(days)
    }
    
    // MARK: - Comparing

    public func startsEarlier(then date: Date) -> Bool {
        return startTime(inDate: date) < date || startTime(inDate: date) == date
    }
    
    public func startsLater(then date: Date) -> Bool {
        return startTime(inDate: date) > date
    }
    
    public func endsLater(then date: Date) -> Bool {
        return finishTime(inDate: date) > date
    }
    
    public func endsEarlier(then date: Date) -> Bool {
        return finishTime(inDate: date) < date
    }
    
    public func startsEarlier(then activity: Activity) -> Bool {
        let date = Date()
        let otherStartTime = activity.startTime(inDate: date)
        let updatedStartTime = startTime(inDate: date)
        return updatedStartTime < otherStartTime
    }
    
    // MARK: - Private functions
    
    private func startTimeNextDay(from date: Date) -> Date {
        let nextDate = nextActionDay(fromDate: date)
        return startTime(inDate: nextDate)
    }
    
    private func nextActionDay(fromDate date: Date = Date()) -> Date {
        let currentDay = Weekday.createFromDate(date)
        
        let nextDayOptions = days.filter { (weekday) -> Bool in
            return weekday.rawValue != currentDay.rawValue
        }
        
        let nextDay = Weekday.closestDay(nextDayOptions, toDay: currentDay)
        let daysInBetween = timeMachine.intervalFromDay(currentDay.rawValue, toDay: nextDay.rawValue)
        let secondsInDay = 24 * 60 * 60
        let nextActionDay = date.addingTimeInterval(daysInBetween * Double(secondsInDay))
        return nextActionDay
    }
    
}

// MARK: - Convenience Initializers

extension Activity {
    
    /// Initializer for creating activity from scratch
    public init(withLifetimeDays
        lifetimeDays: Int,
                name: String,
                days: [Weekday],
                timing: Timing,
                notifications: Bool,
                results: Set<Result> = []) {
        
        self.resourceId = UUID().uuidString
        self.name = name
        self.days = days
        self.timing = timing
        self.notifications = notifications
        self.results = results
        
        self.stats = Stats(
            averageSuccess: 0,
            totalTimeSaved: 0,
            totalResults: 0)
        self.estimates = Estimates(
            withDuration: timing.timeToSave,
            busyDays: days.count,
            totalDays: lifetimeDays)
    }

    
    /// Initializer for converting activity from Data Base
    public init(withEstimates estimates: Estimates,
                name: String,
                days: [Weekday],
                timing: Timing,
                notifications: Bool,
                resourceId: String,
                results: Set<Result>,
                stats: Stats) {
        
        self.resourceId = resourceId
        self.name = name
        self.days = days
        self.timing = timing
        self.notifications = notifications
        self.estimates = estimates
        self.results = results
        self.stats = stats
    }

}
