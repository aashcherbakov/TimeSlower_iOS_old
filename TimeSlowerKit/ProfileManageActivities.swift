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
    
    enum DayOfWeek: Int {
        case Sunday = 1
        case Monday
        case Tuesday
        case Wednesdey
        case Thursday
        case Friday
        case Saturday
        
        static func dayName(givenNumber: Int) -> DayOfWeek {
            let dayOfWeek = (givenNumber + 7 - NSCalendar.currentCalendar().firstWeekday) % 7 + 1
            return DayOfWeek(rawValue: dayOfWeek)!
        }
    }
    
    //MARK: - Activities in general
    
    func allActivities() -> [Activity] {
        var activitiesArray = [Activity]()
        for activity in activities {
            if let checkedActivity = activity as? Activity {
                activitiesArray.append(checkedActivity)
            }
        }
        return activitiesArray
    }
    
    func activitiesForToday() -> [Activity] {
        let todaysDayNumber = NSCalendar.currentCalendar().component(.Weekday, fromDate: NSDate())
        let dayOfWeek = DayOfWeek.dayName(todaysDayNumber)
        return activitiesForWeekday(dayOfWeek)
    }
    
    func doesActivityHappenToday(activity: Activity) -> Bool {
        let todaysDayNumber = NSCalendar.currentCalendar().component(.Weekday, fromDate: NSDate())
        let today = DayOfWeek.dayName(todaysDayNumber)
        
        switch activity.activityBasis() {
        case .Daily:
            return true
        case .Workdays:
            return (today != .Sunday && today != .Saturday) ? true : false
        case .Weekends:
            return today == .Sunday || today == .Saturday ? true : false
        }
    }
    
    func activitiesForWeekday(weekday: DayOfWeek) -> [Activity] {
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
    
    func isTimeIntervalFree(startTime start: NSDate, finish: NSDate, basis: ActivityBasis) -> (Activity?) {
        for activity in allActivities() {
            if activity.activityBasis() == basis || activity.activityBasis() == .Daily {
                // finishTime of tested activity to given startTime
                if activity.updatedFinishTime().earlierDate(start) != activity.updatedFinishTime() {
                    // startTime of tested activity to given finishTime
                    if activity.updatedStartTime().earlierDate(finish) != finish {
                        return activity
                    }
                }
            }
        }
        return nil
    }
    
    func activityHasUniqueTimeInterval(activityToTest: Activity) -> Activity? {
        // delete tested activity
        var activitiesToTest: Set<Activity> = NSSet(array: activitiesForToday()) as! Set<Activity>
        activitiesToTest.remove(activityToTest)
        for activity in activitiesToTest {
            if let preventingActivity = isTimeIntervalFree(startTime: activity.updatedStartTime(),
                finish: activity.updatedFinishTime(),
                basis: activity.activityBasis()) {
                    return preventingActivity
            }
        }
        return nil
    }
    
    func sortActivitiesByTime(arrayOfActivities: [Activity]) -> [Activity] {
        let arrayToSort = arrayOfActivities
        let sortedArray: [Activity] = sorted(arrayToSort, sortByNextActionTime)
        return sortedArray
    }
    
    private func sortByNextActionTime(activity1: Activity, activity2: Activity) -> Bool {
        return activity1.timing.nextActionTime() < activity2.timing.nextActionTime()
    }
    
    func findCurrentActivity() -> Activity {
        for activity in activitiesForToday() {
            if activity.isGoingNow() {
                return activity
            }
        }
        return nextClosestActivity()
    }
    
    func nextClosestActivity() -> Activity {
        let currentDate = NSDate()
        var closestStartTime = currentDate.dateByAddingTimeInterval(60*60*24)
        var nextActivity: Activity!
        
        for activity in activitiesForToday() {
            var startTimeToCheck = activity.updatedStartTime()
            
            // maybe all activities are past due so the next one will be on next day only
            if activity.updatedFinishTime() < currentDate || activity.isDoneForToday() {
                startTimeToCheck = startTimeToCheck.dateByAddingTimeInterval(60*60*24)
            }

            if startTimeToCheck < closestStartTime {
                closestStartTime = startTimeToCheck
                nextActivity = activity
            }
        }
        return nextActivity
    }
    
    //MARK: - Goals
    
    func hasGoals() -> Bool {
        for activity in allActivities() {
            if !activity.isRoutine() { return true }
        }
        return false
    }
    
    func goalsForToday() -> [Activity] {
        var goals = [Activity]()
        for activity in allActivities() {
            if !activity.isRoutine() { goals.append(activity) }
        }
        return goals
    }
    
    
    //MARK: - Routines

}










