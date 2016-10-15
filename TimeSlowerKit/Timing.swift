//
//  Timing.swift
//  TimeSlowerKit
//
//  Created by Oleksandr Shcherbakov on 9/4/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation

public struct Timing {
    public let duration: Endurance
    public let alarmTime: Date
    public let startTime: Date
    public let finishTime: Date
    public var manuallyStarted: Date?
    public let timeToSave: Double
    
    
    public init(withDuration duration: Endurance, startTime: Date, timeToSave: Double, alarmTime: Date, manuallyStarted: Date? = nil) {
        self.duration = duration
        self.startTime = startTime
        self.finishTime = Timing.finishTime(fromStart: startTime, duration: duration)
        self.timeToSave = timeToSave
        self.alarmTime = alarmTime
        self.manuallyStarted = manuallyStarted
    }
    
    private static func finishTime(fromStart startTime: Date,
                                   duration: Endurance) -> Date {
        
        return startTime.addingTimeInterval(duration.seconds())
    }
    
    public func update(withManuallyStarted started: Date?) -> Timing {
        return Timing(withDuration: duration, startTime: startTime, timeToSave: timeToSave, alarmTime: alarmTime, manuallyStarted: started)
    }
}
