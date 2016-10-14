//
//  Result.swift
//  TimeSlowerKit
//
//  Created by Oleksandr Shcherbakov on 9/4/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation

/**
 *  Struct that describes single result for one given day in activity. Is created when activity is finished
 *  manually or automatically.
 */
public struct Result: Persistable {
    
    fileprivate let timeMachine = TimeMachine()
    fileprivate let dateFormatter = StaticDateFormatter.shortDateNoTimeFromatter
    
    public let resourceId: String
    
    /// Short string representation of date to simplify search
    public let stringDate: String
    
    /// Fact start time
    public let startTime: Date
    
    /// Fact finish time
    public let finishTime: Date
    
    /// Fact duration
    public let duration: Double
    
    /// Fact success
    public let success: Double
    
    /// Fact saved time in case this is a result for routine
    public let savedTime: Double?
    
    /// Activity for which result is created
    public let activity: Activity
    
    // MARK: - Public
    
    public init(withActivity activity: Activity, factFinish: Date = Date()) {
        let timing = activity.getTiming()
        
        startTime = activity.startTime(inDate: factFinish)
        finishTime = factFinish
        
        duration = timeMachine.minutesFromStart(startTime, toFinish: factFinish)
        
        success = Result.daySuccessForTiming(timing, activityType: activity.type, startTime: startTime, finishTime: factFinish)
        
        savedTime = Result.factSavedTimeForActivity(activity, factDuration: duration)
        
        stringDate = dateFormatter.string(from: factFinish)
        
        // TODO: update average success for activity
        self.activity = activity
        
        resourceId = UUID().uuidString
    }
    
    /**
     Wrapper that returns Weekday.shortDayNameForDate() using date property (not raughDate!)
     
     - returns: String with short day name
     */
    public func shortDayNameForDate() -> String {
        guard let date = dateFormatter.date(from: stringDate) else {
            return ""
        }
        
        return Weekday.shortDayNameForDate(date)
    }
    
    // MARK: - Internal
    
    /**
     Calculates % of time saved/spent
     
     - returns: Double for % of achieved result
     */
    static func daySuccessForTiming(_ timing: Timing, activityType: ActivityType, startTime: Date, finishTime: Date) -> Double {
        let successCalculator = SuccessCalculator().successForActivityType(activityType)
        let duration = Double(timing.duration.minutes())
        let goal = timing.timeToSave
        return successCalculator(startTime, finishTime, duration, goal)
    }
    
    // MARK: - Private Functions
    
    fileprivate static func factSavedTimeForActivity(_ activity: Activity, factDuration: Double) -> Double {
        if activity.type == .routine {
            return Double(activity.duration().minutes()) - factDuration
        } else {
            return factDuration
        }
    }
}


