//
//  ProfileManageActivities.swift
//  TimeSlower2
//
//  Created by Aleksander Shcherbakov on 5/2/15.
//  Copyright (c) 2015 1lastDay. All rights reserved.
//

import Foundation
import CoreData


extension Profile {
    
    //MARK: - Activities in general
    
    /**
     Transforms NSSet of stored Activities to array
     
     - returns: Array of Activity instances
     */
    public func allActivities() -> [Activity] {
        return activities.allObjects as! [Activity]
    }
    
    /**
     Filters set of activities and returns one with matched name
     
     - parameter passedName: String with name
     
     - returns: Activity if there is one with given name
     */
    public func activityForName(passedName: String) -> Activity? {
        return allActivities().filter { $0.name == passedName }.first
    }
    
    /**
     Searches for all activities that accurs on given date.
     
     - parameter date: NSDate instance
     
     - returns: sorted by next action time Array of Activity instances
     */
    public func activitiesForDate(date: NSDate) -> [Activity] {
        let weekday = Weekday.createFromDate(date)
        let activities = allActivities().filter { $0.fitsWeekday(weekday) }
        return sortActivitiesByTime(activities)
    }
    
    /**
     Checks if time interval is free for creating new activity.
     Made to make sure activities do not overlap with each other.
     
     - parameter start:    NSDate for start time
     - parameter duration: ActivityDuration
     - parameter days:     Array of Weekday instances for activity occurances
     
     - returns: Activity that is occupying given time if there is one
     */
    public func hasActivityScheduledToStart(start: NSDate, duration: ActivityDuration, days: [Weekday]) -> Activity? {
        let activities = allActivities()
        let needStart = TimeMachine().updatedTime(start, forDate: NSDate())
        let needFinish = needStart.dateByAddingTimeInterval(duration.seconds())

        for day in days {
            let weekdayActivities = activities.filter { $0.fitsWeekday(day) }
            for activity in weekdayActivities {
                if activity.occupiesTimeBetween(needStart, finish: needFinish) {
                    return activity
                }
            }
        }
       
        return nil
    }
    
    /**
     Sorts activities by nextActionTime()
     
     - parameter arrayOfActivities: Array of activities
     
     - returns: Sorted Array of Activity instances
     */
    func sortActivitiesByTime(arrayOfActivities: [Activity]) -> [Activity] {
        return arrayOfActivities.sort {
            $0.timing.nextActionTime() < $1.timing.nextActionTime()
        }
    }
    
    /**
     Looks for activity that is going on right now. If there is none, returns next closest activity
     
     - returns: Activity instance
     */
    public func findCurrentActivity() -> Activity? {
        for activity in activitiesForDate(NSDate()) {
            if activity.isGoingNow() {
                return activity
            }
        }
        return nextClosestActivity()
    }
    
    /// Searches for closest activity today and if there are none, gives first activity of tomorrow
    public func nextClosestActivity() -> Activity? {
        if let nextActivityToday = findNextActivityForToday() {
            return nextActivityToday
        } else {
            return findNextActivityInTomorrowList()
        }
    }
    
    public func findNextActivityForToday() -> Activity? {
        var closestStartTime = NSDate().dateByAddingTimeInterval(60*60*24)
        var nextActivity: Activity!
        
        for activity in activitiesForDate(NSDate()) {
            if !activity.isDoneForToday() && !activity.isPassedDueForToday() {
                if activity.updatedStartTime() < (closestStartTime) {
                    closestStartTime = activity.updatedStartTime()
                    nextActivity = activity
                }
            }
        }
        return nextActivity
    }
    
    public func findNextActivityInTomorrowList() -> Activity? {
        let tomorrowActivities = activitiesForDate(NSDate().dateByAddingTimeInterval(60*60*24))
        return (tomorrowActivities.count > 0) ? sortActivitiesByTime(tomorrowActivities).first! : nil
    }
    
    
    
    
    
    
    
    
    
    //MARK: - Goals
    
    public func hasGoals() -> Bool {
        for activity in allActivities() {
            if !activity.isRoutine() { return true }
        }
        return false
    }
    
    public func goalsForToday() -> [Activity] {
        var goals = [Activity]()
        for activity in allActivities() {
            if !activity.isRoutine() { goals.append(activity) }
        }
        return goals
    }
    
}










