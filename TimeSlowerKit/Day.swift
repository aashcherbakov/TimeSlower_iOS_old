//
//  Day.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 4/26/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation
import CoreData

/// Class that defines a day. Used to describe activity basis
open class Day: NSManagedObject, Persistable {
    
    /// Constructor
    open static func createFromWeekday(_ weekday: Weekday, forActivity activity: Activity) -> Day? {
        
        guard let context = activity.managedObjectContext else { return nil }
        
        if let day = NSEntityDescription.insertNewObject(
            forEntityName: String(describing: self), into: context) as? Day {
            day.name = weekday.shortName
            day.number = NSNumber(value: weekday.rawValue as Int)
            saveContext(context)
            return day
        }
        
        return nil
    }
    
    /**
     Transforms Set of Day into array of Int
     
     - parameter days: Day instances
     
     - returns: number properties of Day
     */
    open static func daysIntegerRepresentation(_ days: Set<Day>?) -> [Int] {
        guard let days = days else {
            return [Int]()
        }
        
        var integers = [Int]()
        for day in days {
            integers.append(day.number.intValue)
        }
        
        return integers
    }
    
    /**
     Transforms array of Int into Set of Days
     
     - parameter selectedDays: [Int]
     - parameter activity:     ActivityInstance
     
     - returns: Set of Days
     */
    open static func dayEntitiesFromSelectedDays(_ selectedDays: [Int], forActivity activity: Activity) -> Set<Day> {
        var daySet = Set<Day>()
        for day in selectedDays {
            if let weekday = Weekday(rawValue: day),
                let newDay = Day.createFromWeekday(weekday, forActivity: activity) {
                
                daySet.insert(newDay)
            }
        }
        
        return daySet
    }
}



