//
//  ActivityStore.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 10/12/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation
import TimeSlowerKit

internal final class ActivityCreator {
    
    private let dataStore: DataStore
    
    init(withDataStore dataStore: DataStore = DataStore()) {
        self.dataStore = dataStore
    }
    
    
    /// Creates Activity from given parameters.
    ///
    /// - parameter name:          name String
    /// - parameter selectedDays:  selected days [Int]
    /// - parameter startTime:     Date
    /// - parameter duration:      Endurance instance
    /// - parameter timeToSave:    Int in minutes
    /// - parameter notifications: Bool = true for enabled notifications
    ///
    /// - returns: Activity if all arguments appear to be not-nil
    func createActivity(
        withName name: String?,
        selectedDays: [Int]?,
        startTime: Date?,
        duration: Endurance?,
        timeToSave: Int?,
        notifications: Bool?) -> Activity? {
        
        guard
            let name = name,
            let selectedDays = selectedDays,
            let startTime = startTime,
            let duration = duration,
            let timeToSave = timeToSave,
            let notifications = notifications
        else {
            return nil
        }
        
        let days = weekdaysWith(numbers: selectedDays)
        let activityTiming = timing(withStartTime: startTime, duration: duration, timeToSave: timeToSave)
        let lifetimeDays = totalDaysForProfile()
        
        let activity = Activity(
            withLifetimeDays: lifetimeDays,
            name: name,
            type: .routine,
            days: days,
            timing: activityTiming,
            notifications: notifications)
        
        return dataStore.create(activity)
    }
    
    func saveActivity(
        activity: Activity?,
        name: String?,
        selectedDays: [Int]?,
        startTime: Date?,
        duration: Endurance?,
        timeToSave: Int?,
        notifications: Bool?) -> Activity? {
        
        guard
            let activity = activity,
            let name = name,
            let selectedDays = selectedDays,
            let startTime = startTime,
            let duration = duration,
            let timeToSave = timeToSave,
            let notifications = notifications
            else {
                return nil
        }

        let days = weekdaysWith(numbers: selectedDays)
        let activityTiming = timing(withStartTime: startTime, duration: duration, timeToSave: timeToSave)
        let stats = Stats(withDuration: timeToSave, busyDays: days.count, totalDays: totalDaysForProfile())
        
        let updatedActivity = Activity(
            withStats: stats,
            name: name,
            type: activity.type,
            days: days,
            timing: activityTiming,
            notifications: notifications,
            averageSuccess: activity.averageSuccess,
            resourceId: activity.resourceId,
            results: activity.results,
            totalResults: activity.totalResults,
            totalTimeSaved: activity.totalTimeSaved)
        
        return dataStore.update(updatedActivity)
    }
    
    // MARK: - Private Functions
    
    private func alarmTimeFromStart(startTime: Date, duration: Endurance, timeToSave: Int) -> Date {
        let timeInterval = duration.seconds() - Double(timeToSave * 60)
        return startTime.addingTimeInterval(timeInterval)
    }
    
    private func timing(withStartTime startTime: Date, duration: Endurance, timeToSave: Int) -> Timing {
        let alarmTime = alarmTimeFromStart(startTime: startTime, duration: duration, timeToSave: timeToSave)
        
        let timing = Timing(
            withDuration: duration,
            startTime: startTime,
            timeToSave: timeToSave,
            alarmTime: alarmTime)
        return timing
    }
    
    private func totalDaysForProfile() -> Int {
        if let profile: Profile = dataStore.retrieve("") {
            return profile.numberOfDaysTillEndOfLifeSinceDate(Date())
        }
        
        return 0
    }
    
    private func weekdaysWith(numbers: [Int]) -> [Weekday] {
        return numbers.map { (number) -> Weekday in
            if let weekday = Weekday(rawValue: number) {
                return weekday
            } else {
                fatalError("Day number \(number) excedes number of days in week")
            }
        }
    }
}
