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
    
    class func newStatsForActivity(activity givenActivity: Activity) -> Stats {
        let entity = NSEntityDescription.entityForName("Stats", inManagedObjectContext: givenActivity.managedObjectContext!)
        let stats = Stats(entity: entity!, insertIntoManagedObjectContext: givenActivity.managedObjectContext)
        stats.activity = givenActivity
        
        if !givenActivity.managedObjectContext!.save() { print("Could not save: \(error)") }
        
        print("New stats created: \(stats)")
        return stats
    }
    
    
    func updateAverageSuccess() {
        if activity.results.count > 0 {
            let fetchRequest = NSFetchRequest(entityName: "DayResults")
            fetchRequest.resultType = .DictionaryResultType
            let successToCount = NSExpressionDescription()
            successToCount.name = "averSuccess"
            successToCount.expression = NSExpression(forFunction: "average:", arguments: [NSExpression(forKeyPath: "factSuccess")])
            successToCount.expressionResultType = .DoubleAttributeType
            
            fetchRequest.propertiesToFetch = [successToCount]
            
            var error: NSError?
            let result = managedObjectContext?.executeFetchRequest(fetchRequest, error: &error) as? [NSDictionary]
            if let resultArray = result {
                let resultDict = resultArray[0]
                let averSuccess: AnyObject? = resultDict["averSuccess"]
                let transformingSuccess = "\(averSuccess)"
                self.averageSuccess = NSNumber(integer: transformingSuccess.toInt()!)
            }
        }
    }
    
    // Get total hours spent or saved on activity depending on basis
    func updateStats() {
        let components = NSCalendar.currentCalendar().components(.CalendarUnitDay,
            fromDate: NSDate(),
            toDate: activity.profile.dateOfApproximateLifeEnd(),
            options: nil)
        let daysLeft = components.day
        var hours = 0.0, days = 0.0, months = 0.0, years = 0.0
        
        // Get hours
        var units = (activity.isRoutine()) ? activity.timing.timeToSave.doubleValue : activity.timing.duration.doubleValue
        hours = units * Double(daysLeft) / 60.0

        // Get days
        switch activity.activityBasis() {
        case .Daily: days = hours / 24
        case .Workdays: days = (((hours / 24) / 7) / 5)
        case .Weekends: days = (((hours / 24) / 7) / 2)
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
}