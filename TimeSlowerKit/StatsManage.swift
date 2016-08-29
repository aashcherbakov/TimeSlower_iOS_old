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
    
    /**
     Creates new stats object and assigns it to given activity
     
     - parameter givenActivity: Activity instance
     
     - returns: Stats instance
     */
    public class func newStatsForActivity(activity givenActivity: Activity) -> Stats {
        guard let context = givenActivity.managedObjectContext else {
            fatalError("Passed activity has no context")
        }
        
        guard let entity = NSEntityDescription.entityForName("Stats", inManagedObjectContext: context) else {
            fatalError("Could not find entity with name Stats")
        }
        
        let stats = Stats(entity: entity, insertIntoManagedObjectContext: context)
        stats.activity = givenActivity
        saveContext(context)
        
        return stats
    }

    /**
     Calculates total hours, days, months and years that would be spent on activity in lifetime of user
     
     - parameter date: starting NSDate
     */
    public func updateStatsForDate(date: NSDate) {
        let daysLeft = activity.profile.numberOfDaysTillEndOfLifeSinceDate(date)
        let busyDays = activity.days.count
        let duration = activity.timing.duration.minutes()
        let calculator = TimeCalculator()
        
        // Set activity's properties
        summHours = calculator.totalHours(inDays: daysLeft, duration: duration, busyDays: busyDays)
        summDays = calculator.totalDays(inDays: daysLeft, duration: duration, busyDays: busyDays)
        summMonths = calculator.totalMonths(inDays: daysLeft, duration: duration, busyDays: busyDays)
        summYears = calculator.totalYears(inDays: daysLeft, duration: duration, busyDays: busyDays)
    }
    
    public func updateSuccessWithResult(result: DayResults) {
        guard let results = activity.results where results.count > 0 else {
            averageSuccess = result.factSuccess
            return
        }
        
        let currentSuccess = averageSuccess.doubleValue
        let numberOfResults = Double(results.count)
        let summResultsValue = currentSuccess * numberOfResults + result.factSuccess.doubleValue
        averageSuccess = summResultsValue / (numberOfResults + 1)
    }
    

    
//    /// Can not be tested in XCTests because of InMemory store type bug
//    public func updateAverageSuccess() {
//        guard let results = activity.results, context = managedObjectContext else {
//            return
//        }
//        
//        if results.count > 0 {
//            let fetchRequest = NSFetchRequest(entityName: "DayResults")
//            fetchRequest.resultType = .DictionaryResultType
//            fetchRequest.propertiesToFetch = averageSuccessCalculation()
//            fetchRequest.predicate = NSPredicate(format: "activity.name == %@", activity.name)
//            
//            do {
//                let result = try context.executeFetchRequest(fetchRequest)
//                let resultDict = result[0]
//                let averSuccess: AnyObject? = resultDict["averSuccess"]
//                let transformingSuccess = "\(averSuccess)"
//                averageSuccess = NSNumber(integer: Int(transformingSuccess)!)
//            } catch let error as NSError {
//                print("Error during updating avarage success: \(error)")
//            }
//        }
//    }
    
    
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
    

    // TODO: checkout what to do with this?
    /// Returns total number of days when activity was "on" based on it's basis
    public func busyDaysForPeriod(period: PastPeriod, sinceDate date: NSDate) -> Int {
        let totalDays = TimeMachine().numberOfDaysInPeriod(period, fromDate: date)
        return totalDays / 7 * activity.days.count
        // what if it's today and it only once?
    }
}