//
//  Activity.swift
//  TimeSlowerKit
//
//  Created by Oleksandr Shcherbakov on 9/3/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation

public struct Activity: Persistable {
    
    public let resourceId: String
    public let name: String
    public let type: ActivityType
    public let days: [Weekday]
    public let stats: Stats
    public let notifications: Bool
    public let averageSuccess: Double
    private(set) public var results: Set<Result>
    private let timing: Timing

    private let timeMachine = TimeMachine()
    
    public init(withLifetimeDays
        lifetimeDays: Int,
        name: String,
        type: ActivityType,
        days: [Weekday],
        timing: Timing,
        notifications: Bool, results: Set<Result> = []) {
        
        self.resourceId = UUID().uuidString
        self.name = name
        self.type = type
        self.days = days
        self.timing = timing
        self.notifications = notifications
        self.averageSuccess = 0
        self.results = results
        self.stats = Stats(withDuration: timing.duration.minutes(), busyDays: days.count, totalDays: lifetimeDays)
    }
    
    public init(withStats
        stats: Stats,
        name: String,
        type: ActivityType,
        days: [Weekday],
        timing: Timing,
        notifications: Bool,
        averageSuccess: Double,
        resourceId: String, results: Set<Result>) {
        
        self.resourceId = resourceId
        self.name = name
        self.type = type
        self.days = days
        self.timing = timing
        self.notifications = notifications
        self.averageSuccess = averageSuccess
        self.stats = stats
        self.results = results
    }
    
    public func update(withTiming newTiming: Timing) -> Activity {
        return Activity(
            withStats: stats,
            name: name,
            type: type,
            days: days,
            timing: newTiming,
            notifications:
            notifications,
            averageSuccess: averageSuccess,
            resourceId: resourceId,
            results: results)
    }
    
    public mutating func updateWithResults(results: Set<Result>) {
        self.results = results
    }
    
    public func isDone(forDate date: Date = Date()) -> Bool {
        let searchString = StaticDateFormatter.shortDateNoTimeFromatter.string(from: date)
        let resultsForToday = results.filter { (result) -> Bool in
            return result.stringDate == searchString
        }
        
        return resultsForToday.count > 0
    }
    
    public func nextActionTime(forDate date: Date = Date()) -> Date {
        if isDone(forDate: date) {
            let nextDate = nextActionDay(fromDate: date)
            return startTime(inDate: nextDate)
        } else if isGoingNow() {
            return finishTime()
        } else {
            return startTime()
        }
    }
    
    public func nextActionDay(fromDate date: Date = Date()) -> Date {
        let currentDay = Weekday.createFromDate(date)
        
        let nextDayOptions = days.filter { (weekday) -> Bool in
            return weekday.rawValue != currentDay.rawValue
        }
        
        let nextDay = Weekday.closestDay(nextDayOptions, toDay: currentDay)
        let daysInBetween = numberOfDaysTillDay(day: nextDay.rawValue, fromDay: currentDay.rawValue)
        let nextActionDay = date.addingTimeInterval(Double(daysInBetween * 24 * 60 * 60))
        return nextActionDay
    }
    
    public func numberOfDaysTillDay(day: Int, fromDay: Int) -> Int {
        if day < fromDay {
            return 7 - (fromDay - day)
        } else if day > fromDay {
            return day - fromDay
        } else {
            return 7
        }
    }
    
    public func startTime(inDate date: Date = Date()) -> Date {
        let startTime = timing.manuallyStarted ?? timing.startTime
        return timeMachine.updatedTime(startTime, forDate: date)
    }
    
    public func finishTime(inDate date: Date = Date()) -> Date {
        var factFinishTime = timing.finishTime
        if let manuallyStarted = timing.manuallyStarted {
            factFinishTime = manuallyStarted.addingTimeInterval(timing.duration.seconds())
        }
        
        return timeMachine.updatedTime(factFinishTime, forDate: date)
    }
    
    public func alarmTime(inDate date: Date = Date()) -> Date {
        guard let started = timing.manuallyStarted else {
            return finishTime()
        }
        
        return started.addingTimeInterval(timing.duration.seconds())
    }
    
    public func timeToSave() -> Double {
        return timing.timeToSave
    }
    
    public func updateTiming(withManuallyStarted started: Date?) -> Timing {
        return timing.update(withManuallyStarted: started)
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
    
    public func isGoingNow(date: Date = Date()) -> Bool {
        return startsEarlierThen(date: date) && endsLaterThen(date: date) && !isDone(forDate: date)
    }
    
    public func startsEarlierThen(date: Date) -> Bool {
        let updatedStartTime = timeMachine.updatedTime(startTime(), forDate: date)
        return updatedStartTime.compare(date) == .orderedAscending
    }
    
    public func startsLaterThen(date: Date) -> Bool {
        let updatedStartTime = timeMachine.updatedTime(startTime(), forDate: date)
        return updatedStartTime.compare(date) == .orderedDescending
    }
    
    public func endsLaterThen(date: Date) -> Bool {
        let updatedFinishTime = timeMachine.updatedTime(finishTime(), forDate: date)
        return updatedFinishTime.compare(date) == .orderedDescending
    }
    
    public func startsEarlierThen(activity: Activity) -> Bool {
        let date = Date()
        let currentActivityStartTime = timeMachine.updatedTime(startTime(), forDate: date)
        let otherActivityStartTime = timeMachine.updatedTime(activity.startTime(), forDate: date)
        return currentActivityStartTime.compare(otherActivityStartTime) == .orderedAscending
    }
}

/**
 Enum that describes Activity Type - currently Routine or Goal
 
 - Routine: Routine - daily activity on which user ought to save time
 - Goal:    Goal - activity that user wants to spend time on
 */
public enum ActivityType: Int {
    case routine
    case goal
}

