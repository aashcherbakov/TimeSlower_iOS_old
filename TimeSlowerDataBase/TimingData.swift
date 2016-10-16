//
//  Timing.swift
//  TimeSlowerKit
//
//  Created by Oleksandr Shcherbakov on 9/3/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation


open class TimingData: NSObject {

    open let duration: Continuation
    open let alarmTime: Date
    open let startTime: Date
    open let finishTime: Date
    open let timeToSave: Int
    open var manuallyStarted: Date?
    
    public required init?(coder aDecoder: NSCoder) {
        self.duration = aDecoder.decodeObject(forKey: "duration") as! Continuation
        self.alarmTime = aDecoder.decodeObject(forKey: "alarmTime") as! Date
        self.startTime = aDecoder.decodeObject(forKey: "startTime") as! Date
        self.finishTime = aDecoder.decodeObject(forKey: "finishTime") as! Date
        self.manuallyStarted = aDecoder.decodeObject(forKey: "alarmTime") as? Date
        self.timeToSave = aDecoder.decodeInteger(forKey: "timeToSave")
    }
    
    public init(duration: Continuation, alarmTime: Date, startTime: Date, timeToSave: Int, manuallyStarted: Date? = nil) {
        self.duration = duration
        self.alarmTime = alarmTime
        self.startTime = startTime
        self.manuallyStarted = manuallyStarted
        self.finishTime = startTime.addingTimeInterval(duration.seconds())
        self.timeToSave = timeToSave
    }
    
}

extension TimingData: NSCoding {
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(duration, forKey: "duration")
        aCoder.encode(alarmTime, forKey: "alarmTime")
        aCoder.encode(startTime, forKey: "startTime")
        aCoder.encode(finishTime, forKey: "finishTime")
        aCoder.encode(manuallyStarted, forKey: "manuallyStarted")
        aCoder.encode(timeToSave, forKey: "timeToSave")
    }
}
