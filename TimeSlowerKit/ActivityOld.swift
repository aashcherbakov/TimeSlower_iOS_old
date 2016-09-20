////
////  Activity.swift
////  TimeSlower
////
////  Created by Oleksandr Shcherbakov on 5/7/16.
////  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
////
//
//import Foundation
//import CoreData
//
///// NSManagedObject subclass that stores information about user activity
//open class Activity: NSManagedObject, Persistable {
//    
//    fileprivate let timeMachine = TimeMachine()
//    
//    // TODO: convert properties of activity to Enum
//    open class func typeWithEnum(_ type: ActivityType) -> NSNumber {
//        return NSNumber(value: type.rawValue as Int)
//    }
//    
//    open class func basisWithEnum(_ basis: Basis) -> NSNumber {
//        return NSNumber(value: basis.rawValue as Int)
//    }
//        
//    /**
//     Mark activity as manually started. finishWithResult method must be called after.
//     */
//    open func startActivity() {
//        timing.manuallyStarted = Date()
//    }
//    
//    /**
//     Creates DayResult and assigns it to activity. Also, sets manuallyStarted property to nil.
//     */
//    open func finishWithResult() {
//        DayResults.newResultWithDate(Date(), forActivity: self)
//        timing.manuallyStarted = nil
//    }
//    
//    // MARK: - Comparing activities
//    
//    /**
//     Compares two activities base on their next action time.
//     
//     - parameter otherActivity: Activity instance to which you compare current one
//     
//     - returns: NSComparisonResult. Descending if current activity is earlier.
//     */
//    open func compareBasedOnNextActionTime(_ otherActivity: Activity) -> ComparisonResult {
//        let currentActivityTime = timing.nextActionTime()
//        let otherActivityTime = otherActivity.timing.nextActionTime()
//        return currentActivityTime.compare(otherActivityTime as Date)
//    }
//    
//    /**
//     Checks if activity is happening in given Weekday
//     
//     - parameter weekday: Weekday to check
//     
//     - returns: True if days of activity has this weekday
//     */
//    open func fitsWeekday(_ weekday: Weekday) -> Bool {
//        let fit = days.filter { (day) -> Bool in
//            guard let day = day as? Day else { return false }
//            return day.name == weekday.shortName
//        }
//        
//        return fit.count > 0
//    }
//    
//    /**
//     Checks if activity is occupying given period of time
//     
//     - parameter start:  NSDate for start of period
//     - parameter finish: NSDate for finish
//     
//     - returns: True if period is occupied
//     */
//    open func occupiesTimeBetween(_ start: Date, finish: Date) -> Bool {
//        let updatedStartTime = timeMachine.updatedTime(timing.startTime, forDate: start)
//        let updatedFinishTime = timeMachine.updatedTime(timing.finishTime, forDate: finish)
//
//        if start.compare(updatedFinishTime) == .orderedAscending && updatedStartTime.compare(finish) == .orderedDescending {
//            return true
//        }
//
//        return false
//    }
//    
//    // MARK: - Persistance
//    
//    /**
//     Creates Activity instance and saves it in Profile's context
//     
//     - parameter type:          ActivityType - goal or routine
//     - parameter name:          String for name
//     - parameter selectedDays:  Array of Integers from 0 to 6
//     - parameter startTime:     NSDate
//     - parameter duration:      ActivityDuration instance
//     - parameter notifications: True for enabled notifications
//     - parameter timeToSave:    Int for minutes to be saved
//     - parameter profile:       Profile instance
//     
//     - returns: Activity instance
//     */
//    open static func createActivityWithType(_ type: ActivityType, name: String, selectedDays: [Int], startTime: Date, duration: ActivityDuration, notifications: Bool, timeToSave: Int, forProfile profile: Profile) -> Activity {
//        
//        let activity = Activity.newActivityForProfile(profile, ofType: type)
//        activity.name = name
//        activity.days = Day.dayEntitiesFromSelectedDays(selectedDays, forActivity: activity) as NSSet
//        activity.basis = NSNumber(value: Basis.basisFromDays(selectedDays).rawValue)
//        activity.timing.startTime = startTime
//        activity.timing.finishTime = updateFinishTimeWithDuration(duration, fromStartTime: startTime)
//        activity.timing.duration = duration
//        activity.timing.timeToSave = NSNumber(value: timeToSave)
//        activity.notifications = notifications as NSNumber
//        activity.stats.updateStatsForDate(Date())
//        
//        Activity.saveContext(activity.managedObjectContext)
//        
//        return activity
//    }
//    
//    open static func updateActivityWithParameters(_ activity: Activity, name: String, selectedDays: [Int], startTime: Date, duration: ActivityDuration, notifications: Bool, timeToSave: Int) {
//        
//        activity.name = name
//        activity.days = Day.dayEntitiesFromSelectedDays(selectedDays, forActivity: activity) as NSSet
//        activity.basis = NSNumber(value: Basis.basisFromDays(selectedDays).rawValue)
//        activity.timing.startTime = startTime
//        activity.timing.finishTime = updateFinishTimeWithDuration(duration, fromStartTime: startTime)
//        activity.timing.duration = duration
//        activity.timing.timeToSave = NSNumber(value: timeToSave)
//        activity.notifications = notifications as NSNumber
//        activity.stats.updateStatsForDate(Date())
//        
//        Activity.saveContext(activity.managedObjectContext)
//    }
//    
//    // MARK: - Fetch Results
//    
//    open func allResultsPredicateForPeriod(_ period: PastPeriod) -> NSPredicate {
//        let calendar = TimeMachine()
//        let timePredicate = NSPredicate(format: "raughDate > %@", calendar.startDateForPeriod(period, sinceDate: Date()) as CVarArg)
//        let namePredicate = NSPredicate(format: "activity.name == %@", name)
//        
//        return NSCompoundPredicate(andPredicateWithSubpredicates: [namePredicate, timePredicate])
//    }
//    
//    
//    // MARK: - Notifications
//    
//    open func userInfoForActivity() -> [AnyHashable: Any] {
//        return ["activityName" : name]
//    }
//    
//    open func startTimerNotificationMessage() -> String {
//        var message = ""
//        if isRoutine() {
//            message = "Your goal: save \(timing.timeToSave) min. (or months \(stats.summMonths) of your lifetime"
//        } else {
//            message = "Your goal: spend \(timing.duration) min."
//        }
//        return message
//    }
//    
//    /// Can't be assigned to a Goal (no snooze for a Goal)
//    open func finishTimeNotificationMessage() -> String {
//        return "\(timing.timeToSave) min. left till the end. In order to save \(stats.summMonths) month of your lifetime, you have to finish it now"
//    }
//    
//    open func lastCallNotificationMessage() -> String {
//        return isRoutine() ? "There is no time lest to save on this activity. Try to finish earlier next time." : "Time's up for today! You can finish now"
//    }
//
//    
//    // MARK: - Private Methods
//    
//    fileprivate static func newActivityForProfile(_ userProfile: Profile, ofType: ActivityType) -> Activity {
//        guard let
//            context = userProfile.managedObjectContext,
//            let entity = NSEntityDescription.entity(forEntityName: Activity.className, in: context)
//            else {
//                fatalError("Attempt to create activity with profile that is not in managed object context")
//        }
//        
//        let activity = Activity(entity: entity, insertInto: context)
//        activity.type = Activity.typeWithEnum(ofType)
//        activity.profile = userProfile
//        activity.stats = Stats.newStatsForActivity(activity: activity)
//        activity.timing = Timing.newTimingForActivity(activity: activity)
//        
//        Activity.saveContext(context)
//        return activity
//    }
//    
//    fileprivate static func updateFinishTimeWithDuration(_ duration: ActivityDuration, fromStartTime startTime: Date) -> Date {
//        return startTime.addingTimeInterval(duration.seconds())
//    }
//    
//    /// Workaround method for be used only in UnitTesting
//    open func unitTesting_allResultsForPeriod(_ period: PastPeriod) -> [DayResults] {
//        return []
//    }
//}
