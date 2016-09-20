////
////  Result.swift
////  TimeSlower2
////
////  Created by Aleksander Shcherbakov on 7/4/15.
////  Copyright (c) 2015 1lastDay. All rights reserved.
////
//
//import Foundation
//import CoreData
//
//open class Result: NSManagedObject, Persistable {
//    
//    open class func newResultWithDate(_ date: Date, forActivity activity: Activity) -> Result {
//        let result: Result!
//        
//        // check if there already is result for this date
//        if let fetchedResult = fetchResultWithDate(date, forActivity: activity) {
//            result = fetchedResult
//            activity.timing.manuallyStarted = nil
//            
//        } else {
//            let entity = NSEntityDescription.entity(forEntityName: "Result", in: activity.managedObjectContext!)
//            result = Result(entity: entity!, insertInto: activity.managedObjectContext)
//            result.factFinishTime = date
//            result.raughDate = date
//            result.date = Result.standardDateFormatter().string(from: date)
//            result.factStartTime = activity.timing.updatedStartTimeForDate(date)
////            result.factDuration = TimeMachine().minutesFromStart(result.factStartTime, toFinish: result.factFinishTime)
//            result.factSuccess = NSNumber(value: result.daySuccessForTiming(activity.timing) as Double)
//            
//            activity.stats.updateSuccessWithResult(result)
//            
//            if activity.isRoutine() {
////                result.factSavedTime = activity.timing.duration.minutes() - result.factDuration.intValue
//            }
//            
//            result.activity = activity
//            activity.timing.manuallyStarted = nil
//
//            saveContext(activity.managedObjectContext)
//        }
//        
//        return result
//    }
//    
//    /**
//     Formatter that operates with date in format "8/29/16". Made to compare dates and fetch 
//     results based on simple date.
//     
//     - returns: NSDateFormatter singleton instance
//     */
//    open class func standardDateFormatter() -> DateFormatter {
//        return StaticDateFormatter.shortDateNoTimeFromatter
//    }
//    
//    
//    /**
//     Calculates % of time saved/spent
//     
//     - returns: Double for % of achieved result
//     */
//    open func daySuccessForTiming(_ timing: Timing) -> Double {
//        let successCalculator = Result.successForActivityType(activity.activityType())
//        let duration = Double(timing.duration.minutes())
//        let goal = timing.timeToSave.doubleValue
//        return successCalculator(factStartTime as Date, factFinishTime as Date, duration, goal)
//    }
//    
//    /**
//     Compares results based on dates
//     
//     - parameter otherResult: DayResult instance
//     
//     - returns: NSComparison description
//     */
//    open func compareDatesOfResults(_ otherResult: Result) -> ComparisonResult {
//        let dateFormatter = Result.standardDateFormatter()
//        
//        guard let
//            originalDate = dateFormatter.date(from: date),
//            let otherDate = dateFormatter.date(from: otherResult.date)
//        else {
//            fatalError("Could not convert dates")
//        }
//        return originalDate.compare(otherDate)
//    }
//    
//    /**
//     Wrapper that returns Weekday.shortDayNameForDate() using date property (not raughDate!)
//     
//     - returns: String with short day name
//     */
//    open func shortDayNameForDate() -> String {
//        guard let date = Result.standardDateFormatter().date(from: date) else {
//            return ""
//        }
//        
//        return Weekday.shortDayNameForDate(date)
//    }
//    
//    
//    //MARK: - Fetching
//    
//    /**
//     Fetches result for activity in given date
//     
//     - parameter date:     NSDate for which we search results
//     - parameter activity: Activity instance
//     
//     - returns: Result instance if there is one for given date
//     */
//    open class func fetchResultWithDate(_ date: Date, forActivity activity: Activity) -> Result? {
////        let referenceDate = Result.standardDateFormatter().string(from: date)
////        
////        let fetchRequest = NSFetchRequest(entityName: "Result")
////        let activityNamePredicate = NSPredicate(format: "activity.name == %@", activity.name)
////        let dayOfResultPredicate = NSPredicate(format: "date == %@", referenceDate)
////        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [activityNamePredicate, dayOfResultPredicate])
////        fetchRequest.predicate = compoundPredicate
////        
////        let results = try! activity.managedObjectContext!.fetch(fetchRequest) as! [Result]
////        
////        if let result = results.first {
////            return result
////        } else {
////            return nil
////        }
//        return nil
//    }
//    
//    /**
//     Fetches all results in given context
//     
//     - parameter date:    NSDate for which we search results
//     - parameter context: NSManagedObjectContext
//     
//     - returns: Array of Result for specific date
//     */
//    open class func fetchResultsWithDate(_ date: Date, inContext context: NSManagedObjectContext) -> [Result] {
////        let referenceDate = Result.standardDateFormatter().string(from: date)
////        let fetchRequest = NSFetchRequest(entityName: "Result")
////        fetchRequest.predicate = NSPredicate(format: "date == %@", referenceDate)
////        
////        let results = try! context.fetch(fetchRequest) as! [Result]
////        return results
//        return []
//    }
//    
//    /**
//     Fetches all results, sorts them by date and returns up to 7 latest results
//     
//     - parameter activity: Activity instance
//     
//     - returns: Array of Result
//     */
//    open static func lastWeekResultsForActivity(_ activity: Activity) -> [Result] {
//        guard let results = activity.results else { return [Result]() }
//        
//        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true, selector: #selector(NSString.compareDateRepresentationOfString(_:)))
//
//        if let sortedArray = results.sortedArray(using: [sortDescriptor]) as? [Result] {
//            return removeSpareResults(sortedArray)
//        }
//        
//        return [Result]()
//    }
//
//    /**
//     Defines success of routine
//     
//     - parameter start:       NSDate for fact start
//     - parameter finish:      NSDate for fact finish
//     - parameter maxDuration: Double for initial duration of routine
//     - parameter goal:        Double for time to save of routine
//     
//     - returns: Double for % of success. Can't be negative.
//     */
//    static func successForRoutine(start: Date,
//        finish: Date,
//        maxDuration: Double,
//        goal: Double) -> Double {
//        
//        let factDuration = TimeMachine().minutesFromStart(start, toFinish: finish)
//        let factSavedTime =  maxDuration - factDuration
//        if factSavedTime < 0 {
//            return 0
//        } else {
//            return factSavedTime / goal * 100.0
//        }
//    }
//    
//    /**
//     Defines success for goal base of fact duration and planned duration
//     
//     - parameter start:       NSDate for fact start
//     - parameter finish:      NSDate for fact finish
//     - parameter maxDuration: Double for initial duration of goal
//     - parameter goal:        not used
//     
//     - returns: Double for % of success. Can't be negative.
//     */
//    static func successForGoal(start: Date,
//        finish: Date,
//        maxDuration: Double,
//        goal: Double) -> Double {
//        
//        let factDuration = TimeMachine().minutesFromStart(start, toFinish: finish)
//        if factDuration > 0 {
//            return factDuration / maxDuration * 100.0
//        } else {
//            return 0
//        }
//    }
//    
//    // MARK: - Private Functions
//    
//    fileprivate static func successForActivityType(_ type: ActivityType) -> ((_ start: Date, _ finish: Date, _ maxDuration: Double, _ goal: Double) -> Double) {
//        switch type {
//        case .routine: return successForRoutine
//        case .goal: return successForGoal
//        }
//    }
//    
//    fileprivate static func removeSpareResults(_ results: [Result]) -> [Result] {
//        var sortedArray = results
//        if sortedArray.count > 7 {
//            let lastResultsNumber = (sortedArray.count < 7) ? sortedArray.count : 7
//            sortedArray.removeSubrange(0..<(sortedArray.count - lastResultsNumber))
//        }
//        return sortedArray
//    }
//}
//
