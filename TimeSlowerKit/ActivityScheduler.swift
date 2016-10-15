//
//  ActivityScheduler.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 10/12/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation

public struct ActivityScheduler {
    
    private let dataStore: DataStore
    
    /// Initializer
    ///
    /// - parameter dataStore: Default value = DataStore()
    ///
    /// - returns: ActivityScheduler instance
    public init(withDataStore dataStore: DataStore = DataStore()) {
        self.dataStore = dataStore
    }
    
    /// Returns list of activities for given date using DataStore search
    ///
    /// - parameter date: Date
    ///
    /// - returns: Array of activities
    public func activitiesForDate(date: Date) -> [Activity] {
        return dataStore.activities(forDate: date, type: .routine)
    }
    
    /// Finds next closest activity comparint start times of all activities for date
    ///
    /// - parameter date: default - current date
    ///
    /// - returns: Activity that has start time closest to given Date or nil
    public func nextClosestActivity(forDate date: Date = Date()) -> Activity? {
        let activities = dataStore.activities(forDate: date, type: .routine)
        var closestActivity: Activity?
        
        let unfinishedActivities = activities.filter { (activity) -> Bool in
            return !activity.isDone(forDate: date)
        }
                
        for activity in unfinishedActivities {
            if activity.startsLaterThen(date: date) {
                closestActivity = closestOfActivities(current: closestActivity, next: activity)
            }
        }
        
        return closestActivity
    }
    
    /// Finds current activity for date if any
    ///
    /// - parameter date: current date by default
    ///
    /// - returns: Activity?
    public func currentActivity(date: Date = Date()) -> Activity? {
        let activities = dataStore.activities(forDate: date, type: .routine)
    
        for activity in activities {
            if activity.isGoingNow(date: date) {
                return activity
            }
        }
        
        return nil
    }
    
    /// Marks activity as manuallyStarted and updates it in data base
    ///
    /// - parameter activity: Activity to start
    /// - parameter time:     Time when started. By default = current date
    ///
    /// - returns: Updated activity
    public func start(activity: Activity, time: Date = Date()) -> Activity {
        let newTiming = activity.updateTiming(withManuallyStarted: time)
        let newActivity = activity.update(withTiming: newTiming)
        return dataStore.update(newActivity)
    }
    
    /// Creates a result for activity and saves it to data base. Removes manuallyStarted marter.
    ///
    /// - parameter activity: Activity to finish
    /// - parameter time:     Fact finish time. Current date by default
    ///
    /// - returns: Updated activity
    public func finish(activity: Activity, time: Date = Date()) -> Activity {
        let result = Result(withActivity: activity, factFinish: time)
        let newTiming = activity.updateTiming(withManuallyStarted: nil)
        let newActivity = activity.update(withTiming: newTiming)
        let updatedActivity = dataStore.update(newActivity)
        dataStore.create(result, withParent: updatedActivity)
        return updatedActivity
    }
    
    // MARK: - Private 
    
    private func closestOfActivities(current: Activity?, next: Activity) -> Activity {
        if let closest = current {
            return next.startsEarlierThen(activity: closest) ? next : closest
        } else {
            return next
        }
    }
    
}
