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
    public let timing: Timing
    public let stats: Stats
    public let notifications: Bool
    public let averageSuccess: Double
    
    private let timeMachine = TimeMachine()
    
    public init(withLifetimeDays
        lifetimeDays: Int,
        name: String,
        type: ActivityType,
        days: [Weekday],
        timing: Timing,
        notifications: Bool) {
        
        self.resourceId = UUID().uuidString
        self.name = name
        self.type = type
        self.days = days
        self.timing = timing
        self.notifications = notifications
        self.averageSuccess = 0
        
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
        resourceId: String) {
        
        self.resourceId = resourceId
        self.name = name
        self.type = type
        self.days = days
        self.timing = timing
        self.notifications = notifications
        self.averageSuccess = averageSuccess
        self.stats = stats
    }
    
    public func update(withTiming newTiming: Timing) -> Activity {
        return Activity(withStats: stats, name: name, type: type, days: days, timing: newTiming, notifications: notifications, averageSuccess: averageSuccess, resourceId: resourceId)
    }
    
    
    /// Returns basis constructed of weekdays
    ///
    /// - returns: Basis instance
    public func basis() -> Basis {
        return Basis.basisFromWeekdays(days)
    }
    
    public func isGoingNow(date: Date = Date()) -> Bool {
        return startsEarlierThen(date: date) && endsLaterThen(date: date)
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
    
    public func startTime() -> Date {
        return timing.manuallyStarted ?? timing.startTime
    }
    
    public func finishTime() -> Date {
        var factFinishTime = timing.finishTime
        if let manuallyStarted = timing.manuallyStarted {
            factFinishTime = manuallyStarted.addingTimeInterval(timing.duration.seconds())
        }
        
        return factFinishTime
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

