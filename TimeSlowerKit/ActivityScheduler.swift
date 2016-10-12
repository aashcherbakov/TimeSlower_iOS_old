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
    
    public init(withDataStore dataStore: DataStore = DataStore()) {
        self.dataStore = dataStore
    }
    
    public func activitiesForDate(date: Date) -> [Activity] {
        return dataStore.activities(forDate: date, type: .routine)
    }
    
    public func nextClosestActivity(forDate date: Date = Date()) -> Activity? {
        let activities = dataStore.activities(forDate: date, type: .routine)
        var closestActivity: Activity?
        
        for activity in activities {
            if activity.startsLaterThen(date: date) {
                if let closest = closestActivity {
                    if activity.startsEarlierThen(activity: closest) {
                        closestActivity = activity
                    }
                } else {
                    closestActivity = activity
                }
            }
        }
        
        return closestActivity
    }
    
    private func startsLaterThen(date: Date, activity: Activity) -> Bool {
        return activity.timing.startTime.compare(date) == .orderedDescending
    }
    
    public func currentActivity(date: Date = Date()) -> Activity? {
        return nil
    }
    
    public func start(activity: Activity) {
        
    }
    
    public func finish(activity: Activity) {
        
    }
    
}
