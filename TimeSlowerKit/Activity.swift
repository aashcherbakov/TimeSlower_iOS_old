//
//  Activity.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 5/7/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation
import CoreData

/// NSManagedObject subclass that stores information about user activity
public class Activity: NSManagedObject, Persistable {
    
    private let timeMachine = TimeMachine()
    
    // TODO: convert properties of activity to Enum
    public class func typeWithEnum(type: ActivityType) -> NSNumber {
        return NSNumber(integer: type.rawValue)
    }
    
    public class func basisWithEnum(basis: Basis) -> NSNumber {
        return NSNumber(integer: basis.rawValue)
    }
        
    /**
     Mark activity as manually started. finishWithResult method must be called after.
     */
    public func startActivity() {
        timing.manuallyStarted = NSDate()
    }
    
    /**
     Creates DayResult and assigns it to activity. Also, sets manuallyStarted property to nil.
     */
    public func finishWithResult() {
        DayResults.newResultWithDate(NSDate(), forActivity: self)
        timing.manuallyStarted = nil
    }
    
    // MARK: - Comparing activities
    
    /**
     Compares two activities base on their next action time.
     
     - parameter otherActivity: Activity instance to which you compare current one
     
     - returns: NSComparisonResult. Descending if current activity is earlier.
     */
    public func compareBasedOnNextActionTime(otherActivity: Activity) -> NSComparisonResult {
        let currentActivityTime = timing.nextActionTime()
        let otherActivityTime = otherActivity.timing.nextActionTime()
        return currentActivityTime.compare(otherActivityTime)
    }
    
    /**
     Checks if activity is happening in given Weekday
     
     - parameter weekday: Weekday to check
     
     - returns: True if days of activity has this weekday
     */
    public func fitsWeekday(weekday: Weekday) -> Bool {
        let fit = days.filter { (day) -> Bool in
            guard let day = day as? Day else { return false }
            return day.name == weekday.shortName
        }
        
        return fit.count > 0
    }
    
    /**
     Checks if activity is occupying given period of time
     
     - parameter start:  NSDate for start of period
     - parameter finish: NSDate for finish
     
     - returns: True if period is occupied
     */
    public func occupiesTimeBetween(start: NSDate, finish: NSDate) -> Bool {
        let updatedStartTime = timeMachine.updatedTime(timing.startTime, forDate: start)
        let updatedFinishTime = timeMachine.updatedTime(timing.finishTime, forDate: finish)

        if start < updatedFinishTime && updatedStartTime < finish {
            return true
        }

        return false
    }
    
    // MARK: - Persistance
    
    /**
     Creates Activity instance and saves it in Profile's context
     
     - parameter type:          ActivityType - goal or routine
     - parameter name:          String for name
     - parameter selectedDays:  Array of Integers from 0 to 6
     - parameter startTime:     NSDate
     - parameter duration:      ActivityDuration instance
     - parameter notifications: True for enabled notifications
     - parameter timeToSave:    Int for minutes to be saved
     - parameter profile:       Profile instance
     
     - returns: Activity instance
     */
    public static func createActivityWithType(type: ActivityType, name: String, selectedDays: [Int], startTime: NSDate, duration: ActivityDuration, notifications: Bool, timeToSave: Int, forProfile profile: Profile) -> Activity {
        
        let activity = Activity.newActivityForProfile(profile, ofType: type)
        activity.name = name
        activity.days = Day.dayEntitiesFromSelectedDays(selectedDays, forActivity: activity)
        activity.basis = Basis.basisFromDays(selectedDays).rawValue
        activity.timing.startTime = startTime
        activity.timing.finishTime = updateFinishTimeWithDuration(duration, fromStartTime: startTime)
        activity.timing.duration = duration
        activity.timing.timeToSave = timeToSave
        activity.notifications = notifications
        activity.stats.updateStats()
        
        Activity.saveContext(activity.managedObjectContext)
        
        return activity
    }
    
    public static func updateActivityWithParameters(activity: Activity, name: String, selectedDays: [Int], startTime: NSDate, duration: ActivityDuration, notifications: Bool, timeToSave: Int) {
        
        activity.name = name
        activity.days = Day.dayEntitiesFromSelectedDays(selectedDays, forActivity: activity)
        activity.basis = Basis.basisFromDays(selectedDays).rawValue
        activity.timing.startTime = startTime
        activity.timing.finishTime = updateFinishTimeWithDuration(duration, fromStartTime: startTime)
        activity.timing.duration = duration
        activity.timing.timeToSave = timeToSave
        activity.notifications = notifications
        activity.stats.updateStats()
        
        Activity.saveContext(activity.managedObjectContext)
    }
    
    // MARK: - Fetch Results
    
    public func allResultsPredicateForPeriod(period: PastPeriod) -> NSPredicate {
        let calendar = TimeMachine()
        let timePredicate = NSPredicate(format: "raughDate > %@", calendar.startDateForPeriod(period, sinceDate: NSDate()))
        let namePredicate = NSPredicate(format: "activity.name == %@", name)
        
        return NSCompoundPredicate(andPredicateWithSubpredicates: [namePredicate, timePredicate])
    }
    
    
    // MARK: - Notifications
    
    public func userInfoForActivity() -> [NSObject : AnyObject] {
        return ["activityName" : name]
    }
    
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

    
    // MARK: - Private Methods
    
    private static func newActivityForProfile(userProfile: Profile, ofType: ActivityType) -> Activity {
        guard let
            context = userProfile.managedObjectContext,
            entity = NSEntityDescription.entityForName(Activity.className, inManagedObjectContext: context)
            else {
                fatalError("Attempt to create activity with profile that is not in managed object context")
        }
        
        let activity = Activity(entity: entity, insertIntoManagedObjectContext: context)
        activity.type = Activity.typeWithEnum(ofType)
        activity.profile = userProfile
        activity.stats = Stats.newStatsForActivity(activity: activity)
        activity.timing = Timing.newTimingForActivity(activity: activity)
        
        Activity.saveContext(context)
        return activity
    }
    
    private static func updateFinishTimeWithDuration(duration: ActivityDuration, fromStartTime startTime: NSDate) -> NSDate {
        return startTime.dateByAddingTimeInterval(duration.seconds())
    }
    
    /// Workaround method for be used only in UnitTesting
    public func unitTesting_allResultsForPeriod(period: PastPeriod) -> [DayResults] {
        let fetchRequest = NSFetchRequest(entityName: "DayResults")
        fetchRequest.predicate = allResultsPredicateForPeriod(period)
        
        let results = try! managedObjectContext!.executeFetchRequest(fetchRequest) as! [DayResults]
        
        return results
    }
}
