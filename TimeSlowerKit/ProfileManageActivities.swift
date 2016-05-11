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
    
    public func allActivities() -> [Activity] {
        var activitiesArray = [Activity]()
        for activity in activities {
            if let checkedActivity = activity as? Activity {
                activitiesArray.append(checkedActivity)
            }
        }
        return activitiesArray
    }
    
    public func activityForName(passedName: String) -> Activity? {
        let matchingActivities = allActivities().filter({ $0.name == passedName })
        if matchingActivities.count > 0 { return matchingActivities[0] }
        return nil
    }
    
    public func activitiesForDate(date: NSDate) -> [Activity] {
        let dayOfWeek = LazyCalendar.DayName(rawValue: LazyCalendar.correctWeekdayFromDate(date))
        return sortActivitiesByTime(activitiesForWeekday(dayOfWeek!))
    }
    
    
    
    func activitiesForWeekday(weekday: LazyCalendar.DayName) -> [Activity] {
        var resultArray = [Activity]()
        if weekday == .Saturday || weekday == .Sunday {
            for activity in allActivities() {
                if activity.activityBasis() == .Daily || activity.activityBasis() == .Weekends {
                    resultArray.append(activity)
                }
            }
        } else if weekday != .Saturday && weekday != .Sunday {
            for activity in allActivities() {
                if activity.activityBasis() == .Daily || activity.activityBasis() == .Workdays {
                    resultArray.append(activity)
                }
            }
        }
        return resultArray
    }
    
    
    public func isTimeIntervalFree(startTime start: NSDate, finish: NSDate, basis: Basis) -> Activity? {
        var preventing: Activity?
        for activity in allActivities() {
            if basis == .Daily {
                preventing = checkTimeIntervalForActivity(activity, testedStart: start, testedFinish: finish)
            } else {
                if activity.activityBasis() == basis || activity.activityBasis() == .Daily {
                    preventing = checkTimeIntervalForActivity(activity, testedStart: start, testedFinish: finish)
                }
            }
        }
        return preventing
    }
    
    
    /// Should not be called directly (public for testing reasons)
    public func checkTimeIntervalForActivity(activity: Activity, testedStart: NSDate, testedFinish: NSDate) -> Activity? {
        let start = Timing.updateTimeForToday(testedStart)
        let finish = Timing.updateTimeForToday(testedFinish)
        
        if start < (activity.updatedFinishTime()) {
            if activity.updatedStartTime() < (finish) {
                return activity
            }
        }
        return nil
    }
    
    public func sortActivitiesByTime(arrayOfActivities: [Activity]) -> [Activity] {
        let arrayToSort = arrayOfActivities
        let sortedArray: [Activity] = arrayToSort.sort(sortByNextActionTime)
        return sortedArray
    }
    
    public func sortByNextActionTime(activity1: Activity, activity2: Activity) -> Bool {
        return activity1.timing?.nextActionTime() < (activity2.timing?.nextActionTime())
    }
    
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










