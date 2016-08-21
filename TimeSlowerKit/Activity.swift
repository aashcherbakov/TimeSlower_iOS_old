//
//  Activity.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 5/7/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation
import CoreData

/// NSManagedObject subclass that stores information about user activity
public class Activity: NSManagedObject, Persistable {

    /**
     Creates activity and attaches it to given Profile. 
     Creates empty Stats and Timing objects, transforms ActivityType to Int.
     
     - parameter userProfile: Profile
     - parameter ofType:      ActivityType - routine or goal
     
     - returns: Activity instance
     */
    public class func newActivityForProfile(userProfile: Profile, ofType: ActivityType) -> Activity {
        let entity = NSEntityDescription.entityForName("Activity", inManagedObjectContext: userProfile.managedObjectContext!)
        let activity = Activity(entity: entity!, insertIntoManagedObjectContext: userProfile.managedObjectContext)
        activity.type = Activity.typeWithEnum(ofType)
        activity.profile = userProfile
        activity.stats = Stats.newStatsForActivity(activity: activity)
        activity.timing = Timing.newTimingForActivity(activity: activity)
        
        var error: NSError?
        do {
            try userProfile.managedObjectContext!.save()
        } catch let error1 as NSError { error = error1; print("Could not save activity: \(error)") }
        
        return activity
    }
    
    /// Workaround method for UnitTesting
    public func allResultsForPeriod(period: PastPeriod) -> [DayResults] {
        let fetchRequest = NSFetchRequest(entityName: "DayResults")
        fetchRequest.predicate = allResultsPredicateForPeriod(period)
        
        let results = try! managedObjectContext!.executeFetchRequest(fetchRequest) as! [DayResults]
        
        return results
    }
    
    public func allResultsPredicateForPeriod(period: PastPeriod) -> NSPredicate {
        let calendar = TimeMachine()
        let timePredicate = NSPredicate(format: "raughDate > %@", calendar.startDateForPeriod(period, sinceDate: NSDate()))
        let namePredicate = NSPredicate(format: "activity.name == %@", name)
        
        return NSCompoundPredicate(andPredicateWithSubpredicates: [namePredicate, timePredicate])
    }
}
