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
        guard let results = activity.results, let name = activity.name else {
            return
        }
        
        if results.count > 0 {
            let fetchRequest = NSFetchRequest(entityName: "DayResults")
            fetchRequest.resultType = .DictionaryResultType
            fetchRequest.propertiesToFetch = averageSuccessCalculation()
            fetchRequest.predicate = NSPredicate(format: "activity.name == %@", name)
            
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
        guard let daysLeft = activity.profile?.numberOfDaysTillEndOfLifeSinceDate(NSDate()) else {
            return
        }
        
        var hours = 0.0, days = 0.0, months = 0.0, years = 0.0
        
        // Get hours
        let units = (activity.isRoutine()) ? activity.timing!.timeToSave.doubleValue : Double(activity.timing!.duration.minutes())
        hours = units * Double(daysLeft) / 60.0
        
        // Get days
        switch activity.activityBasis() {
        case .Daily: days = hours / 24
        case .Workdays: days = (((hours / 24) / 7) / 5)
        case .Weekends: days = (((hours / 24) / 7) / 2)
        case .Random: days = hours / 24
        }
        
        // Get months and years
        months = days / 30
        years = months / 12
        
        // Set activity's properties
        summHours = NSNumber(double: hours)
        summDays = NSNumber(double: days)
        summMonths = NSNumber(double: months)
        summYears = NSNumber(double: years)
    }
    
    /// Returns total number of days when activity was "on" based on it's basis
    public func busyDaysForPeriod(period: LazyCalendar.Period, sinceDate date: NSDate) -> Int {
        var days = 0
        
        if period == .Today { days = 1 }
        
        if period == .LastYear && activity.activityBasis() == .Daily {
            return LazyCalendar.numberOfDaysInPeriod(period, fromDate: date)
        }
        
        if period == .Lifetime {
            return busyDaysInLifetimeSinceDate(date)
        }
        
        let dayNames = Activity.dayNamesForBasis(activity.activityBasis())
        for weekday in dayNames {
            let currentDayName = LazyCalendar.DayName(rawValue: weekday)!
            days += LazyCalendar.numberOfWeekdaysNamed(currentDayName, forPeriod: period, sinceDate: date)
        }
        return days
    }
    
    public func busyDaysInLifetimeSinceDate(date: NSDate) -> Int {
        if let totalDays = activity.profile?.numberOfDaysTillEndOfLifeSinceDate(date) {
            switch activity.activityBasis() {
            case .Daily: return totalDays
            case .Workdays: return totalDays / 7 * 5
            case .Weekends: return totalDays / 7 * 2
            case .Random: return totalDays
            }
        }
        
        return 0
    }
    
    
    
    
    //MARK: - LifeTime stats
    
    /// Makes a prognose based on current success in activity.
    /// Returns struct with years, month, days and hours
    public func factTimingInLifetime() -> LifeTime? {
        guard let timing = activity.timing,
            let profile = activity.profile,
            let stats = activity.stats else {
            return nil
        }
        let dailyTime = activity.isRoutine() ? timing.timeToSave.doubleValue : Double(timing.duration.minutes())
        let totalTimePlanned = profile.totalTimeForDailyMinutes(dailyTime)
        let successFroNow = stats.averageSuccess.doubleValue / 100
        
        return LifeTime(years: totalTimePlanned.years * successFroNow,
            months: totalTimePlanned.months * successFroNow,
            days: totalTimePlanned.days * successFroNow,
            hours: totalTimePlanned.hours * successFroNow)
    }
    
    public func plannedTimingInLifetime() -> Profile.LifeTime? {
        var toSave = 0.0
        var toSpend = 0.0
        
        guard let profile = activity.profile else {
            return nil
        }
        
        for anActivity in profile.allActivities() {
            if let timing = anActivity.timing {
                if anActivity.isRoutine() {
                    toSave += timing.timeToSave.doubleValue
                } else {
                    toSpend += Double(timing.duration.minutes())
                }
            }
        }
        let timingForRoutines = profile.totalTimeForDailyMinutes(toSave)
        let timingForGoals = profile.totalTimeForDailyMinutes(toSpend)
        return activity.isRoutine() ? timingForRoutines : timingForGoals
    }
    
    /// Cannot be tested in InMemoryStoreType
    public func fastFactSavedForPeriod(period: LazyCalendar.Period) -> Double {
        var summSavedTimeLastYear = 0.0
        
        let fetchRequest = NSFetchRequest(entityName: "DayResults")
        fetchRequest.resultType = .DictionaryResultType
        fetchRequest.predicate = allResultsPredicateForPeriod(period)
        fetchRequest.propertiesToFetch = propertiesToFetch()
        
        do {
            let result = try! managedObjectContext?.executeFetchRequest(fetchRequest) as! [NSDictionary]
            let resultDict = result[0]
            summSavedTimeLastYear = resultDict["summSaved"] as! Double
            
        }
        return summSavedTimeLastYear
    }
    
    private func allResultsPredicateForPeriod(period: LazyCalendar.Period) -> NSPredicate {
        guard let name = activity.name else {
            fatalError()
        }
        
        let timePredicate = NSPredicate(format: "raughDate > %@", LazyCalendar.startDateForPeriod(period, sinceDate: NSDate()))
        let namePredicate = NSPredicate(format: "activity.name == %@", name)
        if period != .Lifetime {
            return NSCompoundPredicate(andPredicateWithSubpredicates: [namePredicate, timePredicate])
        } else {
            return namePredicate
        }
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
    
    //TODO: Move to Acitivity
    /// Workaround method for UnitTesting
    public func allResultsForPeriod(period: LazyCalendar.Period) -> [DayResults] {
        let fetchRequest = NSFetchRequest(entityName: "DayResults")
        fetchRequest.predicate = allResultsPredicateForPeriod(period)
        
        let results = try! activity.managedObjectContext!.executeFetchRequest(fetchRequest) as! [DayResults]
        
        return results
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}