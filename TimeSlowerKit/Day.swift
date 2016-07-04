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
}



