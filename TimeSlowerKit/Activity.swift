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

