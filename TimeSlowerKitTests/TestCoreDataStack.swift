//
//  TestCoreDataStack.swift
//  TimeSlower2
//
//  Created by Aleksander Shcherbakov on 6/25/15.
//  Copyright (c) 2015 1lastDay. All rights reserved.
//

import Foundation
import CoreData
import TimeSlowerKit

public class TestCoreDataStack: CoreDataStack {
        
    override init() {
        super.init()
        self.persistentStoreCoordinator = {
            
            let testManagedObjectModel = self.managedObjectModel.copy() as! NSManagedObjectModel
            for entity in testManagedObjectModel.entities {
                if entity.name == "DayResults" {
                    entity.managedObjectClassName = "TimeSlowerKitTests.DayResults"
                }
                if entity.name == "Activity" {
                    entity.managedObjectClassName = "TimeSlowerKitTests.Activity"
                }
                if entity.name == "Timing" {
                    entity.managedObjectClassName = "TimeSlowerKitTests.Timing"
                }
                if entity.name == "Profile" {
                    entity.managedObjectClassName = "TimeSlowerKitTests.Profile"
                }
                if entity.name == "Stats" {
                    entity.managedObjectClassName = "TimeSlowerKitTests.Stats"
                }
            }
            
            let psc: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: testManagedObjectModel)
            var error: NSError? = nil
            
            var ps: NSPersistentStore?
            do {
                ps = try psc!.addPersistentStoreWithType(NSInMemoryStoreType,
                                configuration: nil, URL: nil, options: nil)
            } catch let error1 as NSError {
                error = error1
                ps = nil
            } catch {
                fatalError()
            }
            if ps == nil {
                abort()
            }
            return psc
        }()
    }
    
    public func fakeProfile() -> Profile {
        let fakeProfile = Profile.userProfileInManagedContext(self.managedObjectContext)
        fakeProfile.name = "Mike Tyson"
        return fakeProfile
    }
    
    /// Creates activity with name "Morning shower" with built in timing
    ///
    /// - Duration: 30 min
    /// - Time to save: 10 min
    /// - Start time: 10:15 AM
    /// - Finish time: 10:45 AM
    public func fakeActivityWithProfile(profile: Profile, type: Activity.ActivityType, basis: Activity.ActivityBasis) -> Activity {
        let fakeActivity = Activity.newActivityForProfile(profile, ofType: type)
        fakeActivity.basis = Activity.basisWithEnum(basis)
        fakeActivity.busyDays = Activity.defaultBusyDaysForBasis(Activity.ActivityBasis(rawValue: fakeActivity.basis.integerValue)!)
        fakeActivity.name = "Morning shower"
        fakeActivity.timing = fakeTimingForActivity(fakeActivity)
        return fakeActivity
    }
    
    
    
    public func fakeTimingForActivity(activity: Activity) -> Timing {
        let newTiming = Timing.newTimingForActivity(activity: activity)
        newTiming.startTime = shortStyleDateFormatter().dateFromString("7/3/15, 10:15 AM")!
        newTiming.finishTime = shortStyleDateFormatter().dateFromString("7/3/15, 10:45 AM")!
        newTiming.updateDuration()
        newTiming.timeToSave = NSNumber(double: 10.0)
        newTiming.activity = activity
        return newTiming
    }
    
    /// Saved 7 min
    public func fakeResultForActivity(activity: Activity) -> DayResults {
        let newResult = DayResults.newResultWithDate(NSDate(), forActivity: activity)
        newResult.date = DayResults.standardDateFormatter().stringFromDate(NSDate())
        newResult.factFinishTime = activity.updatedFinishTime().dateByAddingTimeInterval(-5*60)
        newResult.activity.timing.manuallyStarted = activity.updatedStartTime().dateByAddingTimeInterval(2*60)
        newResult.factStartTime = newResult.activity.timing.manuallyStarted!
        newResult.factSuccess = NSNumber(double: newResult.daySuccess())
        
        newResult.factDuration = NSNumber(double: abs(newResult.factFinishTime.timeIntervalSinceDate(newResult.factStartTime) / 60))
        
        if activity.isRoutine() {
            newResult.factSavedTime = NSNumber(double: activity.timing.duration.doubleValue - newResult.factDuration.doubleValue)
        }
        
        newResult.activity.timing.manuallyStarted = nil
        return newResult
    }
    
    
    /// Converts dates with format: "7/3/15, 10:15 AM"
    public func shortStyleDateFormatter() -> NSDateFormatter {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .ShortStyle
        dateFormatter.timeStyle = .ShortStyle
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        return dateFormatter
    }
}
