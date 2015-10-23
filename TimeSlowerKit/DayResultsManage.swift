//
//  ResultsManage.swift
//  TimeSlower2
//
//  Created by Aleksander Shcherbakov on 5/4/15.
//  Copyright (c) 2015 1lastDay. All rights reserved.
//

import Foundation
import CoreData

extension DayResults {
    class func newResultForActivity(activity: Activity) {
        
        let entity = NSEntityDescription.entityForName("DayResults", inManagedObjectContext: activity.managedObjectContext!)
        let result = DayResults(entity: entity!, insertIntoManagedObjectContext: activity.managedObjectContext)
        result.activity = activity
        result.factFinishTime = NSDate()
        result.factStartTime = activity.updatedStartTime()
        result.factSuccess = NSNumber(double: result.daySuccess())
        result.date = result.standardDateFormatter().stringFromDate(NSDate())
        
        var error: NSError?
        if !activity.managedObjectContext!.save(&error) { print("Could not save: \(error)") }
        
        print("New result created: \(result)")
    }
    
    func standardDateFormatter() -> NSDateFormatter {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .ShortStyle
        dateFormatter.timeStyle = .NoStyle
        return dateFormatter
    }
    
    func daySuccess() -> Double {
        var success = 0.0
        var factDuration = factFinishTime.timeIntervalSinceDate(factStartTime)
        if factDuration < 0 { factDuration = factDuration * -1 }
        
        if self.activity.isRoutine() {
            let timeToSave = self.activity.timing.timeToSave.doubleValue * 60
            let factSavedTime = (self.activity.timing.duration.doubleValue * 60) - factDuration
            if factSavedTime < 0 {
                return success
            } else {
                success = factSavedTime / timeToSave * 100.0
            }
        } else {
            success = factDuration / (activity.timing.duration.doubleValue * 60) * 100.0
        }
        return success
    }
    
    func compareDatesOfResults(otherResult: DayResults) -> NSComparisonResult {
        let dateFormatter = standardDateFormatter()
        let originalDate = dateFormatter.dateFromString(date)
        let otherDate = dateFormatter.dateFromString(otherResult.date)
        return originalDate!.compare(otherDate!)
    }
    
    func shortDayNameForDate() -> String {
        let dateFormatter = standardDateFormatter()
        let formalDate = dateFormatter.dateFromString(date)
        let dayNumber = NSCalendar.currentCalendar().component(.CalendarUnitWeekday, fromDate: formalDate!)
        var dayName = ""
        switch dayNumber {
            case 1: dayName = "SUN"
            case 2: dayName = "MON"
            case 3: dayName = "TUE"
            case 4: dayName = "WED"
            case 5: dayName = "THU"
            case 6: dayName = "FRI"
            case 7: dayName = "SAT"
        default: break
        }
        return dayName
    }
}
