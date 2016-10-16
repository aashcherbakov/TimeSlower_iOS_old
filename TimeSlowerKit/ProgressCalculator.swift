//
//  ProgressCalculator.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 10/13/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation

/// Data Structure that holds success, saved time and planned time
public struct RoutineProgress {
    public let success: Double
    public let savedTime: Double
    public let plannedTime: Double
}

public struct ProgressCalculator {
    private let dataStore: DataStore
    private let dateFormatter = StaticDateFormatter.shortDateNoTimeFromatter
    
    public init(withDataStore dataStore: DataStore = DataStore()) {
        self.dataStore = dataStore
    }
    
    public func progressForDate(date: Date = Date()) -> RoutineProgress {
        let activities = dataStore.activities(forDate: date, type: .routine)
        let stringDate = dateFormatter.string(from: date)
                
        if let results: [Result] = dataStore.retrieveAll(stringDate) {
            let timeToSave = totalTimeToSave(fromActivities: activities)
            let routineResults = resultsForToday(results: results, activities: activities)
            let routineProgress = routineProgressFromResults(results: routineResults, plannedToSave: timeToSave)
            return routineProgress
        }
        
        return RoutineProgress(success: 0, savedTime: 0, plannedTime: 0)
    }
    
    // MARK: - Private Functions
    
    private func totalTimeToSave(fromActivities activities: [Activity]) -> Double {
        var timeToSave = 0.0
        for activity in activities {
            timeToSave += activity.timeToSave()
        }
        return timeToSave
    }
    
    private func routineProgressFromResults(results: [Result], plannedToSave: Double) -> RoutineProgress {
        var savedTime = 0.0
        
        for result in results {
            if let saved = result.savedTime {
                savedTime += saved
            }
        }
        
        let totalSuccess = savedTime / 100 * plannedToSave
        
        return RoutineProgress(success: totalSuccess, savedTime: savedTime, plannedTime: plannedToSave)
    }
    
    private func resultsForToday(results: [Result], activities: [Activity]) -> [Result] {
        return results.filter { (result) -> Bool in
            return activities.contains(where: { (activity) -> Bool in
                activity.resourceId == result.activity.resourceId
            })
        }
    }
}


