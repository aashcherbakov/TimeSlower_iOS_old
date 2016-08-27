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
            result.activity = activity
            result.factFinishTime = date
            result.raughDate = date
            result.date = DayResults.standardDateFormatter().stringFromDate(date)
            result.factStartTime = activity.timing.updatedStartTimeForDate(date)
            result.factDuration = factDurationFromStart(result.factStartTime, toFinish: result.factFinishTime)
            
            
            
            result.factSuccess = NSNumber(double: result.daySuccess())
            
            if activity.isRoutine() {
                result.factSavedTime = activity.timing.duration.minutes() - result.factDuration.integerValue
            }
            
            activity.timing.manuallyStarted = nil
            
            var error: NSError?
            do {
                try activity.managedObjectContext!.save()
            } catch let error1 as NSError { error = error1; print("Could not save: \(error)") }
        }
        return result
    }
    
    public class func standardDateFormatter() -> NSDateFormatter {
        return StaticDateFormatter.shortDateNoTimeFromatter
    }
    

    
    // in % of goal achieved
    /**
     Calculates % of time saved/spent
     
     - returns: Double for % of achieved result
     */
    public func daySuccess() -> Double {
        var success = 0.0
        var factDuration = factFinishTime.timeIntervalSinceDate(factStartTime) / 60
        
        if factDuration > Double(activity.timing.duration.minutes()) {
            factDuration = Double(activity.timing.duration.minutes())
        }
        
        if factDuration < 0 { factDuration = factDuration * -1 }
        
        if self.activity.isRoutine() {
            let timeToSave = activity.timing.timeToSave.doubleValue
            let factSavedTime = Double(activity.timing.duration.minutes()) - factDuration
            if factSavedTime < 0 {
                return success
            } else {
                success = factSavedTime / timeToSave * 100.0
            }
        } else {
            success = factDuration / (Double(activity.timing.duration.minutes())) * 100.0
        }
        return round(success)
    }
    
    
    public func factSpentTime() -> Double {
        var timeFromStartToFinish = factFinishTime.timeIntervalSinceDate(factStartTime)
        if timeFromStartToFinish < 0 { timeFromStartToFinish = -1.0 * timeFromStartToFinish }
        return timeFromStartToFinish / 60
    }
    
    
    public func compareDatesOfResults(otherResult: DayResults) -> NSComparisonResult {
        let dateFormatter = DayResults.standardDateFormatter()
        let originalDate = dateFormatter.dateFromString(date)
        let otherDate = dateFormatter.dateFromString(otherResult.date)
        return originalDate!.compare(otherDate!)
    }
    
    public func shortDayNameForDate() -> String {
        let dateFormatter = DayResults.standardDateFormatter()
        let daySymbols = dateFormatter.shortWeekdaySymbols
        
        let formalDate = dateFormatter.dateFromString(date)
        let weekday = NSCalendar.currentCalendar().component(.Weekday, fromDate: formalDate!)
        let weekdayNumberForArray = (weekday - 1) % 7
        let dayName: String = daySymbols[weekdayNumberForArray]
        
        return dayName
    }
    
    public class func lastWeekResultsForActivity(activity: Activity) -> [DayResults] {
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true, selector: #selector(NSString.compareDateRepresentationOfString(_:)))
        var sortedArray = activity.results!.sortedArrayUsingDescriptors([sortDescriptor])
        if sortedArray.count > 7 {
            if sortedArray.count > 0 {
                let lastResultsNumber = (sortedArray.count < 7) ? sortedArray.count : 7
                sortedArray.removeRange(0..<(sortedArray.count - lastResultsNumber))
            }
        }
        return sortedArray as! [DayResults]
    }
    
    
    //MARK: - Fetching
    
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
    
    public class func fetchResultsWithDate(date: NSDate, inContext context: NSManagedObjectContext) -> [DayResults] {
        let referenceDate = DayResults.standardDateFormatter().stringFromDate(date)
        
        let fetchRequest = NSFetchRequest(entityName: "DayResults")
        fetchRequest.predicate = NSPredicate(format: "date == %@", referenceDate)
        
        let results = try! context.executeFetchRequest(fetchRequest) as! [DayResults]
        return results
    }
    
    // MARK: - Private Functions
    
    // tested
    private class func factDurationFromStart(start: NSDate, toFinish finish: NSDate) -> Double {
        let timeFromStartToFinish = start.timeIntervalSinceDate(finish)
        return abs(timeFromStartToFinish) / 60
    }

}

