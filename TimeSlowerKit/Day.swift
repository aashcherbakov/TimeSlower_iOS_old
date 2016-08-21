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
public class Day: NSManagedObject, Persistable {
    
    /// Constructor
    public static func createFromWeekday(weekday: Weekday, forActivity activity: Activity) -> Day? {
        
        guard let context = activity.managedObjectContext else { return nil }
        
        if let day = NSEntityDescription.insertNewObjectForEntityForName(
            String(self), inManagedObjectContext: context) as? Day {
            day.name = weekday.shortName
            day.number = NSNumber(integer: weekday.rawValue)
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
    public static func daysIntegerRepresentation(days: Set<Day>?) -> [Int] {
        guard let days = days else {
            return [Int]()
        }
        
        var integers = [Int]()
        for day in days {
            integers.append(day.number.integerValue)
        }
        
        return integers
    }
    
    /**
     Transforms array of Int into Set of Days
     
     - parameter selectedDays: [Int]
     - parameter activity:     ActivityInstance
     
     - returns: Set of Days
     */
    public static func dayEntitiesFromSelectedDays(selectedDays: [Int], forActivity activity: Activity) -> Set<Day> {
        var daySet = Set<Day>()
        for day in selectedDays {
            if let weekday = Weekday(rawValue: day),
                newDay = Day.createFromWeekday(weekday, forActivity: activity) {
                
                daySet.insert(newDay)
            }
        }
        
        return daySet
    }
}



