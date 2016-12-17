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
    public let type: ActivityType
    public let days: [Weekday]
    public let notifications: Bool
    public let estimates: Estimates
    public let stats: Stats
    public let timing: Timing

    // MARK: - Internal properties

    private(set) public var results: Set<Result>

    // MARK: - Private properties

    private let timeMachine = TimeMachine()

    /// Initializer for creating activity from scratch
    public init(withLifetimeDays
        lifetimeDays: Int,
        name: String,
        type: ActivityType,
        days: [Weekday],
        timing: Timing,
        notifications: Bool,
        results: Set<Result> = []) {
        
        self.resourceId = UUID().uuidString
        self.name = name
        self.type = type
        self.days = days
        self.timing = timing
        self.notifications = notifications
        self.results = results
        self.stats = Stats(averageSuccess: 0, totalTimeSaved: 0, totalResults: 0)
        self.estimates = Estimates(withDuration: timing.timeToSave, busyDays: days.count, totalDays: lifetimeDays)
    }
    
    /// Initializer for converting activity from Data Base
    public init(withEstimates estimates: Estimates,
                name: String,
                type: ActivityType,
                days: [Weekday],
                timing: Timing,
                notifications: Bool,
                averageSuccess: Double,
                resourceId: String,
                results: Set<Result>,
                totalResults: Int,
                totalTimeSaved: Double) {
        
        self.resourceId = resourceId
        self.name = name
        self.type = type
        self.days = days
        self.timing = timing
        self.notifications = notifications
        self.estimates = estimates
        self.results = results
        self.stats = Stats(
            averageSuccess: averageSuccess,
            totalTimeSaved: totalTimeSaved,
            totalResults: totalResults)
    }
    
    public func update(withTiming newTiming: Timing) -> Activity {
        return Activity(
            withEstimates: estimates,
            name: name,
            type: type,
            days: days,
            timing: newTiming,
            notifications: notifications,
            averageSuccess: stats.averageSuccess,
            resourceId: resourceId,
            results: results,
            totalResults: stats.totalResults,
            totalTimeSaved: stats.totalTimeSaved)
    }
    
    public func lastWeekResults() -> [Result] {
        // TODO: find faster way to get last 7 results
        let sortedResults = results.sorted {
            $0.finishTime.compare($1.finishTime) == .orderedDescending
        }
        
        let firstSeven = Array(sortedResults.prefix(7))
        return firstSeven
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
        let daysInBetween = timeMachine.intervalFromDay(currentDay.rawValue, toDay: nextDay.rawValue)
        let secondsInDay = 24 * 60 * 60
        let nextActionDay = date.addingTimeInterval(daysInBetween * Double(secondsInDay))
        return nextActionDay
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
        let startsBefore = startsEarlierThen(date: date)
        let endsAfter = endsLaterThen(date: date)
        let notDoneYet = !isDone(forDate: date)
        return startsBefore && endsAfter && notDoneYet
    }
    
    public func isUnfinished(forDate date: Date = Date()) -> Bool {
        let started = timing.manuallyStarted != nil
        let pastDue = endsEarlierThen(date: date)
        return started && pastDue
    }
    
    public func startsEarlierThen(date: Date) -> Bool {
        return startTime(inDate: date).compare(date) == .orderedAscending || startTime(inDate: date).compare(date) == .orderedSame
    }
    
    public func startsLaterThen(date: Date) -> Bool {
        return startTime(inDate: date).compare(date) == .orderedDescending
    }
    
    public func endsLaterThen(date: Date) -> Bool {
        return finishTime(inDate: date).compare(date) == .orderedDescending
    }
    
    public func endsEarlierThen(date: Date) -> Bool {
        return finishTime(inDate: date).compare(date) == .orderedAscending
    }
    
    public func startsEarlierThen(activity: Activity) -> Bool {
        let date = Date()
        let otherStartTime = activity.startTime(inDate: date)
        let updatedStartTime = startTime(inDate: date)
        return updatedStartTime.compare(otherStartTime) == .orderedAscending
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