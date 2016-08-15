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
    
    public func userInfoForActivity() -> [NSObject : AnyObject] {
        return ["activityName" : name]
    }
    
    // MARK: - Convenience setters
    public class func typeWithEnum(type: ActivityType) -> NSNumber {
        return NSNumber(integer: type.rawValue)
    }
    
    public class func basisWithEnum(basis: Basis) -> NSNumber {
        return NSNumber(integer: basis.rawValue)
    }
    
    public func startActivity() {
        timing.manuallyStarted = NSDate()
    }
    
    
    // MARK: - Property convenience
    public func isRoutine() -> Bool {
        return (type.integerValue == 0) ? true : false
    }
    
    public func activityType() -> ActivityType {
        return ActivityType(rawValue: self.type.integerValue)!
    }
    
    public func activityBasis() -> Basis {
        return Basis(rawValue: self.basis.integerValue)!
    }
    
    // MARK: - Results for activity
    public func finishWithResult() {
        DayResults.newResultWithDate(NSDate(), forActivity: self)
    }
    
    public func lastWeekResults() -> [DayResults] {
        return DayResults.lastWeekResultsForActivity(self)
    }
    
    //MARK: - Timing convenience
    public func isPassedDueForToday() -> Bool { return timing.isPassedDueForToday() }
    public func isGoingNow() -> Bool { return timing.isGoingNow() }
    public func isDoneForToday() -> Bool { return timing.isDoneForToday() }
    public func isManuallyStarted() -> Bool { return timing.manuallyStarted != nil }
    public func updatedStartTime() -> NSDate { return timing.updatedStartTime() }
    public func updatedFinishTime() -> NSDate { return timing.updatedFinishTime() }
    public func updatedAlarmTime() -> NSDate { return timing.updatedAlarmTime() }
    
    //MARK: - Data for notifications
    public func startTimerNotificationMessage() -> String {
        var message = ""
        if isRoutine() {
            message = "Your goal: save \(timing.timeToSave) min. (or months \(stats.summMonths) of your lifetime"
        } else {
            message = "Your goal: spend \(timing.duration) min."
        }
        return message
    }
    
    /// Can't be assigned to a Goal (no snooze for a Goal)
    public func finishTimeNotificationMessage() -> String {
        return "\(timing.timeToSave) min. left till the end. In order to save \(stats.summMonths) month of your lifetime, you have to finish it now"
    }
    
    public func lastCallNotificationMessage() -> String {
        return isRoutine() ? "There is no time lest to save on this activity. Try to finish earlier next time." : "Time's up for today! You can finish now"
    }
    
    // MARK: - Comparing activities
    public func compareBasedOnNextActionTime(otherActivity: Activity) -> NSComparisonResult {
        let thisDate = timing.nextActionTime()
        let otherDate = otherActivity.timing.nextActionTime()
        return thisDate.compare(otherDate)
    }
}

