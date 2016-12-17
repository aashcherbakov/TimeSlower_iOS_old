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
    public let timeToSave: Int
    
    private let timeMachine = TimeMachine()
    
    public init(withDuration duration: Endurance, startTime: Date, timeToSave: Int, alarmTime: Date, manuallyStarted: Date? = nil) {
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
        return Timing(
            withDuration: duration,
            startTime: startTime, timeToSave: timeToSave, alarmTime: alarmTime, manuallyStarted: started)
    }
    
    public func starts(inDate date: Date = Date()) -> Date {
        let starts = manuallyStarted ?? startTime
        return timeMachine.updatedTime(starts, forDate: date)
    }

    public func finishes(inDate date: Date = Date()) -> Date {
        let startingPoint = starts(inDate: date)
        let finishTime = startingPoint.addingTimeInterval(duration.seconds())
        return finishTime
    }

    public func alarm(inDate date: Date = Date()) -> Date {
        guard let started = manuallyStarted else {
            return finishes(inDate: date)
        }

        let durationInSeconds = duration.seconds()
        let timeToSaveInSeconds = Double(timeToSave) * 60
        let timeInterval = durationInSeconds - timeToSaveInSeconds
        return started.addingTimeInterval(timeInterval)
    }
}
