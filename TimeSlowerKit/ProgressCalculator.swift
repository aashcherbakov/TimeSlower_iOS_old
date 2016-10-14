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
    private let profile: Profile
    private let dataStore: DataStore
    private let dateFormatter = StaticDateFormatter.shortDateNoTimeFromatter
    
    public init(withProfile profile: Profile, dataStore: DataStore = DataStore()) {
        self.profile = profile
        self.dataStore = dataStore
    }
    
    public func progressForDate(date: Date = Date()) -> RoutineProgress {
        let activities = dataStore.activities(forDate: date, type: .routine)
        let stringDate = dateFormatter.string(from: date)
        
        if let results: [Result] = dataStore.retrieveAll(stringDate) {
            let routineResults = resultsForToday(results: results, activities: activities)
            let routineProgress = routineProgressFromResults(results: routineResults)
            return routineProgress
        }
        
        return RoutineProgress(success: 0, savedTime: 0, plannedTime: 0)
    }
    
    // MARK: - Private Functions
    
    private func routineProgressFromResults(results: [Result]) -> RoutineProgress {
        var totalSuccess = 0.0
        var savedTime = 0.0
        var plannedToSave = 0.0
        
        for result in results {
            totalSuccess += result.success
            plannedToSave += result.activity.timeToSave()
            if let saved = result.savedTime {
                savedTime += saved
            }
        }
        
        var averageSuccess = totalSuccess
        if results.count > 0 {
            averageSuccess = totalSuccess / Double(results.count)
        }
        
        return RoutineProgress(success: averageSuccess, savedTime: savedTime, plannedTime: plannedToSave)
    }
    
    private func resultsForToday(results: [Result], activities: [Activity]) -> [Result] {
        return results.filter { (result) -> Bool in
            return activities.contains(where: { (activity) -> Bool in
                activity.resourceId == result.activity.resourceId
            })
        }
    }
}


