//
//  DayResults.swift
//  TimeSlower2
//
//  Created by Aleksander Shcherbakov on 7/4/15.
//  Copyright (c) 2015 1lastDay. All rights reserved.
//

import Foundation
import CoreData

public class DayResults: NSManagedObject, Persistable {
    
    public class func newResultWithDate(date: NSDate, forActivity activity: Activity) -> DayResults {
        let result: DayResults!
        
        // check if there already is result for this date
        if let fetchedResult = fetchResultWithDate(date, forActivity: activity) {
            result = fetchedResult
            activity.timing.manuallyStarted = nil
            
        } else {
            let entity = NSEntityDescription.entityForName("DayResults", inManagedObjectContext: activity.managedObjectContext!)
            result = DayResults(entity: entity!, insertIntoManagedObjectContext: activity.managedObjectContext)
            result.factFinishTime = date
            result.raughDate = date
            result.date = DayResults.standardDateFormatter().stringFromDate(date)
            result.factStartTime = activity.timing.updatedStartTimeForDate(date)
            result.factDuration = TimeMachine().minutesFromStart(result.factStartTime, toFinish: result.factFinishTime)
            result.factSuccess = NSNumber(double: result.daySuccessForTiming(activity.timing))
            
            activity.stats.updateSuccessWithResult(result)
            
            if activity.isRoutine() {
                result.factSavedTime = activity.timing.duration.minutes() - result.factDuration.integerValue
            }
            
            result.activity = activity
            activity.timing.manuallyStarted = nil

            saveContext(activity.managedObjectContext)
        }
        
        return result
    }
    
    /**
     Formatter that operates with date in format "8/29/16". Made to compare dates and fetch 
     results based on simple date.
     
     - returns: NSDateFormatter singleton instance
     */
    public class func standardDateFormatter() -> NSDateFormatter {
        return StaticDateFormatter.shortDateNoTimeFromatter
    }
    
    
    /**
     Calculates % of time saved/spent
     
     - returns: Double for % of achieved result
     */
    public func daySuccessForTiming(timing: Timing) -> Double {
        let successCalculator = DayResults.successForActivityType(activity.activityType())
        let duration = Double(timing.duration.minutes())
        let goal = timing.timeToSave.doubleValue
        return successCalculator(start: factStartTime, finish: factFinishTime, maxDuration: duration, goal: goal)
    }
    
    /**
     Compares results based on dates
     
     - parameter otherResult: DayResult instance
     
     - returns: NSComparison description
     */
    public func compareDatesOfResults(otherResult: DayResults) -> NSComparisonResult {
        let dateFormatter = DayResults.standardDateFormatter()
        
        guard let
            originalDate = dateFormatter.dateFromString(date),
            otherDate = dateFormatter.dateFromString(otherResult.date)
        else {
            fatalError("Could not convert dates")
        }
        return originalDate.compare(otherDate)
    }
    
    /**
     Wrapper that returns Weekday.shortDayNameForDate() using date property (not raughDate!)
     
     - returns: String with short day name
     */
    public func shortDayNameForDate() -> String {
        guard let date = DayResults.standardDateFormatter().dateFromString(date) else {
            return ""
        }
        
        return Weekday.shortDayNameForDate(date)
    }
    
    
    //MARK: - Fetching
    
    /**
     Fetches result for activity in given date
     
     - parameter date:     NSDate for which we search results
     - parameter activity: Activity instance
     
     - returns: DayResults instance if there is one for given date
     */
    public class func fetchResultWithDate(date: NSDate, forActivity activity: Activity) -> DayResults? {
        let referenceDate = DayResults.standardDateFormatter().stringFromDate(date)
        
        let fetchRequest = NSFetchRequest(entityName: "DayResults")
        let activityNamePredicate = NSPredicate(format: "activity.name == %@", activity.name)
        let dayOfResultPredicate = NSPredicate(format: "date == %@", referenceDate)
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [activityNamePredicate, dayOfResultPredicate])
        fetchRequest.predicate = compoundPredicate
        
        let results = try! activity.managedObjectContext!.executeFetchRequest(fetchRequest) as! [DayResults]
        
        if let result = results.first {
            return result
        } else {
            return nil
        }
    }
    
    /**
     Fetches all results in given context
     
     - parameter date:    NSDate for which we search results
     - parameter context: NSManagedObjectContext
     
     - returns: Array of DayResults for specific date
     */
    public class func fetchResultsWithDate(date: NSDate, inContext context: NSManagedObjectContext) -> [DayResults] {
        let referenceDate = DayResults.standardDateFormatter().stringFromDate(date)
        let fetchRequest = NSFetchRequest(entityName: "DayResults")
        fetchRequest.predicate = NSPredicate(format: "date == %@", referenceDate)
        
        let results = try! context.executeFetchRequest(fetchRequest) as! [DayResults]
        return results
    }
    
    /**
     Fetches all results, sorts them by date and returns up to 7 latest results
     
     - parameter activity: Activity instance
     
     - returns: Array of DayResults
     */
    public static func lastWeekResultsForActivity(activity: Activity) -> [DayResults] {
        guard let results = activity.results else { return [DayResults]() }
        
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true, selector: #selector(NSString.compareDateRepresentationOfString(_:)))

        if let sortedArray = results.sortedArrayUsingDescriptors([sortDescriptor]) as? [DayResults] {
            return removeSpareResults(sortedArray)
        }
        
        return [DayResults]()
    }

    /**
     Defines success of routine
     
     - parameter start:       NSDate for fact start
     - parameter finish:      NSDate for fact finish
     - parameter maxDuration: Double for initial duration of routine
     - parameter goal:        Double for time to save of routine
     
     - returns: Double for % of success. Can't be negative.
     */
    static func successForRoutine(start
        start: NSDate,
        finish: NSDate,
        maxDuration: Double,
        goal: Double) -> Double {
        
        let factDuration = TimeMachine().minutesFromStart(start, toFinish: finish)
        let factSavedTime =  maxDuration - factDuration
        if factSavedTime < 0 {
            return 0
        } else {
            return factSavedTime / goal * 100.0
        }
    }
    
    /**
     Defines success for goal base of fact duration and planned duration
     
     - parameter start:       NSDate for fact start
     - parameter finish:      NSDate for fact finish
     - parameter maxDuration: Double for initial duration of goal
     - parameter goal:        not used
     
     - returns: Double for % of success. Can't be negative.
     */
    static func successForGoal(start
        start: NSDate,
        finish: NSDate,
        maxDuration: Double,
        goal: Double) -> Double {
        
        let factDuration = TimeMachine().minutesFromStart(start, toFinish: finish)
        if factDuration > 0 {
            return factDuration / maxDuration * 100.0
        } else {
            return 0
        }
    }
    
    // MARK: - Private Functions
    
    private static func successForActivityType(type: ActivityType) -> ((start: NSDate, finish: NSDate, maxDuration: Double, goal: Double) -> Double) {
        switch type {
        case .Routine: return successForRoutine
        case .Goal: return successForGoal
        }
    }
    
    private static func removeSpareResults(results: [DayResults]) -> [DayResults] {
        var sortedArray = results
        if sortedArray.count > 7 {
            let lastResultsNumber = (sortedArray.count < 7) ? sortedArray.count : 7
            sortedArray.removeRange(0..<(sortedArray.count - lastResultsNumber))
        }
        return sortedArray
    }
}

