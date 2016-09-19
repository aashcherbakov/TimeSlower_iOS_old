//
//  ActivityManage.swift
//  TimeSlower2
//
//  Created by Aleksander Shcherbakov on 5/2/15.
//  Copyright (c) 2015 1lastDay. All rights reserved.
//

import Foundation
import CoreData

extension Activity {
    
    // MARK: - Property convenience
    
    /**
     Checks type if it's routine or not
     
     - returns: True if type is Routine
     */
    public func isRoutine() -> Bool {
        return (type.intValue == 0) ? true : false
    }
    
    /**
     Converts stored in core data type to ActivityType
     
     - returns: ActivityType
     */
    public func activityType() -> ActivityType {
        return ActivityType(rawValue: self.type.intValue)!
    }
    
    /**
     Converts stored in core data basis to Basis
     
     - returns: Basis
     */
    public func activityBasis() -> Basis {
        return Basis(rawValue: self.basis.intValue)!
    }
    
    /**
     Fetches results for last week
     
     - returns: [DayResults]
     */
    public func lastWeekResults() -> [DayResults] {
        return DayResults.lastWeekResultsForActivity(self)
    }
    
    //MARK: - Timing convenience
    
    public func isPassedDueForToday() -> Bool { return timing.isPassedDueForToday() }
    public func isGoingNow() -> Bool { return timing.isGoingNow() }
    public func isDoneForToday() -> Bool { return timing.isDoneForToday() }
    public func isManuallyStarted() -> Bool { return timing.manuallyStarted != nil }
    public func updatedStartTime() -> Date { return timing.updatedStartTime() as Date }
    public func updatedFinishTime() -> Date { return timing.updatedFinishTime() as Date }
    public func updatedAlarmTime() -> Date { return timing.updatedAlarmTime() as Date }
}

