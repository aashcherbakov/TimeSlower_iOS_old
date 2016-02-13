//
//  ActivityManage.swift
//  TimeSlower2
//
//  Created by Aleksander Shcherbakov on 5/2/15.
//  Copyright (c) 2015 1lastDay. All rights reserved.
//

import Foundation
import CoreData

public enum ActivityType: Int {
    case Routine
    case Goal
}

public enum ActivityBasis: Int {
    case Daily
    case Workdays
    case Weekends
    
    public func description() -> String {
        switch self {
        case .Daily: return "Daily"
        case .Workdays: return "Workdays"
        case .Weekends: return "Weekends"
        }
    }
}

extension Activity {
    
    public class func defaultBusyDaysForBasis(basis: ActivityBasis) -> String {
        switch basis {
        case .Daily: return "Mon Tue Wed Thu Fri Sat Sun"
        case .Workdays: return "Mon Tue Wed Thu Fri"
        case .Weekends: return "Sat Sun"
        }
    }
    
    public class func dayNamesForBasis(basis: ActivityBasis) -> [String] {
        return defaultBusyDaysForBasis(basis).componentsSeparatedByString(" ")
    }
    
    public class func newActivityForProfile(userProfile: Profile, ofType: ActivityType) -> Activity {
        let entity = NSEntityDescription.entityForName("Activity", inManagedObjectContext: userProfile.managedObjectContext!)
        let activity = Activity(entity: entity!, insertIntoManagedObjectContext: userProfile.managedObjectContext)
        activity.type = Activity.typeWithEnum(ofType)
        activity.profile = userProfile
        activity.stats = Stats.newStatsForActivity(activity: activity)
        activity.timing = Timing.newTimingForActivity(activity: activity)
        
        var error: NSError?
        do {
            try userProfile.managedObjectContext!.save()
        } catch let error1 as NSError { error = error1; print("Could not save activity: \(error)") }
        
        return activity
    }
    
    public func userInfoForActivity() -> [NSObject : AnyObject] {
        return ["activityName" : name]
    }
    
    // MARK: - Convenience setters
    public class func typeWithEnum(type: ActivityType) -> NSNumber {
        return NSNumber(integer: type.rawValue)
    }
    
    public class func basisWithEnum(basis: ActivityBasis) -> NSNumber {
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
    
    public func activityBasis() -> ActivityBasis {
        return ActivityBasis(rawValue: self.basis.integerValue)!
    }
    
    public func activityBasisDescription() -> String {
        var stringBasis = ""
        switch activityBasis() {
        case .Daily: stringBasis = "Daily"
        case .Workdays: stringBasis = "Workdays"
        case .Weekends: stringBasis = "Weekends"
        }
        return stringBasis
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
    func compareBasedOnNextActionTime(otherActivity: Activity) -> NSComparisonResult {
        let thisDate = timing.nextActionTime()
        let otherDate = otherActivity.timing.nextActionTime()
        return thisDate.compare(otherDate)
    }
}

extension NSString {
    func compareDateRepresentationOfString(otherString: String) -> NSComparisonResult {
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeStyle = .NoStyle
        dateFormatter.dateStyle = .ShortStyle
        
        let firstDate = dateFormatter.dateFromString(self as String)
        let secondDate = dateFormatter.dateFromString(otherString)
        return firstDate!.compare(secondDate!)
    }
}