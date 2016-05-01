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
    
    required public override init() {
        super.init()
        self.persistentStoreCoordinator = {
            
            let psc = NSPersistentStoreCoordinator(
                managedObjectModel: self.managedObjectModel)
            
            do {
                try psc.addPersistentStoreWithType(
                    NSInMemoryStoreType, configuration: nil,
                    URL: nil, options: nil)
            } catch {
                fatalError()
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
    public func fakeActivityWithProfile(profile: Profile, type: ActivityType, basis: ActivityBasis) -> Activity {
        let fakeActivity = Activity.newActivityForProfile(profile, ofType: type)
        fakeActivity.basis = Activity.basisWithEnum(basis)
//        fakeActivity.busyDays = Activity.defaultBusyDaysForBasis(ActivityBasis(rawValue: fakeActivity.basis.integerValue)!)
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
