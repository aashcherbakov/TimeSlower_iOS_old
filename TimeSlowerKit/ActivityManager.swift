//
//  ActivityManager.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 7/4/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation

/**
 *  Struct responsible for creating instance of Activity from given parameters as
 *  well as setting up default parameters. For instance, update stats.
 */
public struct ActivityManager {
    
    public init() { }
    
    public func createActivityWithType(type: ActivityType, name: String, selectedDays: [Int], startTime: NSDate, duration: ActivityDuration, notifications: Bool, timeToSave: Int, forProfile profile: Profile) -> Activity {
        
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
    
    public func updateActivityWithParameters(activity: Activity, name: String, selectedDays: [Int], startTime: NSDate, duration: ActivityDuration, notifications: Bool, timeToSave: Int) {
        
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
    
    // MARK: - Private Methods
    
    private func updateFinishTimeWithDuration(duration: ActivityDuration, fromStartTime startTime: NSDate) -> NSDate {
        return startTime.dateByAddingTimeInterval(duration.seconds())
    }
}