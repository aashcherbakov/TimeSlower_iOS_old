//
//  ActivityStatsManage.swift
//  TimeSlower2
//
//  Created by Aleksander Shcherbakov on 5/2/15.
//  Copyright (c) 2015 1lastDay. All rights reserved.
//

import Foundation
import CoreData


extension Stats {
    
    private struct Constants {
        let numberOfWeeksInMonth = 4.345
        let numberOfWeeksInYear = 52.0
    }
    
    public struct LifeTime {
        public var years: Double
        public var months: Double
        public var days: Double
        public var hours: Double
    }
    
    public class func newStatsForActivity(activity givenActivity: Activity) -> Stats {
        let entity = NSEntityDescription.entityForName("Stats", inManagedObjectContext: givenActivity.managedObjectContext!)
        let stats = Stats(entity: entity!, insertIntoManagedObjectContext: givenActivity.managedObjectContext)
        stats.activity = givenActivity
        
        var error: NSError?
        do {
            try givenActivity.managedObjectContext!.save()
        } catch let error1 as NSError { error = error1; print("Could not save: \(error)") }
        
        return stats
    }
    
    /// Can not be tested in XCTests because of InMemory store type bug
    public func updateAverageSuccess() {
        guard let results = activity.results else {
            return
        }
        
        if results.count > 0 {
            let fetchRequest = NSFetchRequest(entityName: "DayResults")
            fetchRequest.resultType = .DictionaryResultType
            fetchRequest.propertiesToFetch = averageSuccessCalculation()
            fetchRequest.predicate = NSPredicate(format: "activity.name == %@", activity.name)
            
            do {
                let result = try managedObjectContext!.executeFetchRequest(fetchRequest)
                let resultDict = result[0]
                let averSuccess: AnyObject? = resultDict["averSuccess"]
                let transformingSuccess = "\(averSuccess)"
                self.averageSuccess = NSNumber(integer: Int(transformingSuccess)!)
            } catch let error as NSError {
                print("Error during updating avarage success: \(error)")
            }
        }
    }
    

    // Get total hours spent or saved on activity depending on basis
    public func updateStats() {
        let daysLeft = activity.profile.numberOfDaysTillEndOfLifeSinceDate(NSDate())
        let busyDays = activity.days.count
        let duration = activity.timing.duration.minutes()
        let calculator = TimeCalculator()
        
        // Set activity's properties
        summHours = calculator.totalHours(inDays: daysLeft, duration: duration, busyDays: busyDays)
        summDays = calculator.totalDays(inDays: daysLeft, duration: duration, busyDays: busyDays)
        summMonths = calculator.totalMonths(inDays: daysLeft, duration: duration, busyDays: busyDays)
        summYears = calculator.totalYears(inDays: daysLeft, duration: duration, busyDays: busyDays)
    }
    
    /// Returns total number of days when activity was "on" based on it's basis
    public func busyDaysForPeriod(period: PastPeriod, sinceDate date: NSDate) -> Int {
        var days = 0
        let calendar = TimeMachine()
        
        if period == .Today { days = 1 }
        
        if period == .LastYear && activity.activityBasis() == .Daily {
            return calendar.numberOfDaysInPeriod(period, fromDate: date)
        }
        
        if let dayNames = activity.days as? Set<Day> {
            for weekday in dayNames {
//                days += calendar.numberOfWeekdaysNamed(currentDayName, forPeriod: period, sinceDate: date)
            }
        }
        
        
        return days
    }
    
    public func busyDaysInLifetimeSinceDate(date: NSDate) -> Int {
        let totalDays = activity.profile.numberOfDaysTillEndOfLifeSinceDate(date)
        
        switch activity.activityBasis() {
        case .Daily: return totalDays
        case .Workdays: return totalDays / 7 * 5
        case .Weekends: return totalDays / 7 * 2
        case .Random: return totalDays
        }
    }
    
    
    
    
    //MARK: - LifeTime stats
    
    /// Makes a prognose based on current success in activity.
    /// Returns struct with years, month, days and hours
    public func factTimingInLifetime() -> LifeTime? {
        let dailyTime = activity.isRoutine() ? activity.timing.timeToSave.doubleValue : Double(activity.timing.duration.minutes())
        let totalTimePlanned = activity.profile.totalTimeForDailyMinutes(dailyTime)
        let successFroNow = activity.stats.averageSuccess.doubleValue / 100
        
        return LifeTime(years: totalTimePlanned.years * successFroNow,
            months: totalTimePlanned.months * successFroNow,
            days: totalTimePlanned.days * successFroNow,
            hours: totalTimePlanned.hours * successFroNow)
    }
    
    public func plannedTimingInLifetime() -> Profile.LifeTime? {
        var toSave = 0.0
        var toSpend = 0.0
        
        for anActivity in activity.profile.allActivities() {
            if anActivity.isRoutine() {
                toSave += activity.timing.timeToSave.doubleValue
            } else {
                toSpend += Double(activity.timing.duration.minutes())
            }
        }
        let timingForRoutines = activity.profile.totalTimeForDailyMinutes(toSave)
        let timingForGoals = activity.profile.totalTimeForDailyMinutes(toSpend)
        return activity.isRoutine() ? timingForRoutines : timingForGoals
    }
    
    /// Cannot be tested in InMemoryStoreType
    public func fastFactSavedForPeriod(period: PastPeriod) -> Double {
        var summSavedTimeLastYear = 0.0
        
        let fetchRequest = NSFetchRequest(entityName: "DayResults")
        fetchRequest.resultType = .DictionaryResultType
        fetchRequest.predicate = activity.allResultsPredicateForPeriod(period)
        fetchRequest.propertiesToFetch = propertiesToFetch()
        
        do {
            let result = try! managedObjectContext?.executeFetchRequest(fetchRequest) as! [NSDictionary]
            let resultDict = result[0]
            summSavedTimeLastYear = resultDict["summSaved"] as! Double
            
        }
        return summSavedTimeLastYear
    }
    

    
    private func propertiesToFetch() -> [NSExpressionDescription] {
        let summExpressionDesc = NSExpressionDescription()
        summExpressionDesc.name = "summSaved"
        summExpressionDesc.expression = NSExpression(forFunction: "sum:", arguments: [NSExpression(forKeyPath: "factSavedTime")])
        summExpressionDesc.expressionResultType = .DoubleAttributeType
        return [summExpressionDesc]
    }
    
    private func averageSuccessCalculation() -> [NSExpressionDescription] {
        let successToCount = NSExpressionDescription()
        successToCount.name = "averSuccess"
        successToCount.expression = NSExpression(forFunction: "average:", arguments: [NSExpression(forKeyPath: "factSuccess")])
        successToCount.expressionResultType = .DoubleAttributeType
        return [successToCount]
    }
    

    
}