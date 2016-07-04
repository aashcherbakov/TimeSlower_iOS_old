//
//  ActivityManager.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 7/4/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation

public struct ActivityManager {
    
    public init() { }
    
    public func createActivityWithType(type: ActivityType, name: String, selectedDays: [Int], startTime: NSDate, duration: Int, notifications: Bool, timeToSave: Int, forProfile profile: Profile) -> Activity {
        
        let activity = Activity.newActivityForProfile(profile, ofType: type)
        activity.name = name
        activity.days = dayEntitiesFromSelectedDays(selectedDays, forActivity: activity)
        activity.basis = DateManager.basisFromDays(selectedDays).rawValue
        activity.timing?.startTime = startTime
        activity.timing?.finishTime = updateFinishTimeWithDuration(duration, fromStartTime: startTime)
        activity.timing?.duration = duration
        activity.timing?.timeToSave = timeToSave
        activity.notifications = notifications
        
        do {
            try activity.managedObjectContext?.save()
        } catch let error as NSError {
            print("Could not save activity: \(error)")
        }
        
        return activity
    }
    
    private func updateFinishTimeWithDuration(duration: Int, fromStartTime startTime: NSDate) -> NSDate {
        return startTime.dateByAddingTimeInterval(Double(duration) * 60)
    }
    
    private func dayEntitiesFromSelectedDays(selectedDays: [Int], forActivity activity: Activity) -> Set<Day> {
        var daySet = Set<Day>()
        for day in selectedDays {
            if let weekday = Weekday(rawValue: day),
                newDay = Day.createFromWeekday(weekday, forActivity: activity) {
                
                daySet.insert(newDay)
            }
        }
        
        return daySet
    }
}