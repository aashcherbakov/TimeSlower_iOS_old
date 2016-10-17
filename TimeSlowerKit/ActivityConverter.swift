//
//  ActivityConverter.swift
//  TimeSlowerKit
//
//  Created by Oleksandr Shcherbakov on 9/7/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import TimeSlowerDataBase

internal struct ActivityConverter: PersistableConverter {
    
    func objectFromEntity(_ entity: ManagedObject, parentObject: Persistable?) -> Persistable {
        guard let
            entity = entity as? ActivityEntity,
            let activityType = ActivityType(rawValue: entity.type.intValue)
            else {
                fatalError("Wrong type")
        }
        
        let days = weekdaysFromDays(entity.days)
        let timing = timingFromTimingData(entity.timing)
        let stats = statsFromStatsData(entity.stats)
        
        
        var activity = Activity(
            withStats: stats,
            name: entity.name,
            type: activityType,
            days: days,
            timing: timing,
            notifications: entity.notifications.boolValue,
            averageSuccess: entity.averageSuccess.doubleValue,
            resourceId: entity.resourceId,
            results: [],
            totalResults: entity.totalResults.intValue,
            totalTimeSaved: entity.totalTimeSaved.doubleValue)
        
        let results = resultsFromEntities(resultEntities: entity.results as? Set<ResultEntity>, activity: activity)
        activity.updateWithResults(results: results)
        
        return activity
    }

    func configurationFromObject(_ object: Persistable) -> EntityConfiguration {
        guard let object = object as? Activity else {
            fatalError("Wrong object type")
        }
        
        return ActivityConfiguration(
            name: object.name, 
            type: object.type.rawValue, 
            days: dayNumbersFromWeekdays(object.days), 
            timing: timingDataFromTiming(object.getTiming()),
            stats: statsDataFromStats(object.stats), 
            notifications: object.notifications, 
            resourceId: object.resourceId)
    }
    
    // MARK: - Private Functions
    
    private func resultsFromEntities(resultEntities: Set<ResultEntity>?, activity: Activity) -> Set<Result> {
        let resultsConverter = ResultConverter()
        if let resultEntities = resultEntities,
            let results = resultsConverter.objectsFromEntities(Array(resultEntities), parent: activity) as? [Result] {
            return Set(results)
        }
        
        return []
    }
    
    fileprivate func weekdaysFromDays(_ days: [Day]) -> [Weekday] {
        return days.map { (day) -> Weekday in
            if let weekday = Weekday(rawValue: day.number) {
                return weekday
            } else {
                fatalError("Day number \(day.number) excedes number of days in week")
            }
        }
    }
    
    fileprivate func dayNumbersFromWeekdays(_ weekdays: [Weekday]) -> [Int] {
        return weekdays.map { (weekday) -> Int in
            return weekday.rawValue
        }
    }
    
    fileprivate func timingFromTimingData(_ data: TimingData) -> Timing {
        let duration = enduranceFromContinuation(data.duration)
        
        return Timing(
            withDuration: duration,
            startTime: data.startTime,
            timeToSave: data.timeToSave,
            alarmTime: data.alarmTime,
            manuallyStarted: data.manuallyStarted)
    }
    
    fileprivate func timingDataFromTiming(_ timing: Timing) -> TimingData {
        let continuation = continuationFromEndurance(timing.duration)
        return TimingData(
            duration: continuation, 
            alarmTime: timing.alarmTime,
            startTime: timing.startTime,
            timeToSave: timing.timeToSave,
            manuallyStarted: timing.manuallyStarted)
    }
    
    fileprivate func statsFromStatsData(_ data: StatsData) -> Stats {
        return Stats(
            hours: data.summHours,
            days: data.summDays,
            months: data.summMonths,
            years: data.summYears)
    }
    
    fileprivate func statsDataFromStats(_ stats: Stats) -> StatsData {
        return StatsData(
            days: stats.summDays,
            hours: stats.summHours, 
            months: stats.summMonths, 
            years: stats.summYears)
    }
    
    fileprivate func enduranceFromContinuation(_ continuation: Continuation) -> Endurance {
        guard let period = Period(rawValue: continuation.period.rawValue) else {
            fatalError("Could not map Period enum")
        }
        
        let duration = Endurance(value: continuation.value, period: period)
        return duration
    }
    
    fileprivate func continuationFromEndurance(_ endurance: Endurance) -> Continuation {
        guard let period = PeriodData(rawValue: endurance.period.rawValue) else {
            fatalError("Could not map Period enum")
        }
        
        return Continuation(value: endurance.value, period: period)
    }
    
}
