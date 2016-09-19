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

open class TestCoreDataStack: CoreDataStack {
    
    required public override init() {
        super.init()
        self.persistentStoreCoordinator = {
            
            let psc = NSPersistentStoreCoordinator(
                managedObjectModel: self.managedObjectModel)
            
            do {
                try psc.addPersistentStore(
                    ofType: NSInMemoryStoreType, configurationName: nil,
                    at: nil, options: nil)
            } catch {
                fatalError()
            }
            
            return psc
        }()
    }
    
    open func fakeProfile() -> Profile {
        guard let entity = NSEntityDescription.entity(forEntityName: "Profile", in: managedObjectContext!) else {
            fatalError("No entity named Profile in given context")
        }

        let profile = Profile(entity: entity, insertInto: managedObjectContext!)
        profile.name = "Mike Tyson"
        profile.birthday = Profile.defaultBirthday()
        profile.country = Profile.defaultCountry()
        profile.gender = 0
        profile.dateOfDeath = profile.dateOfApproximateLifeEnd()
        
        Profile.saveContext(managedObjectContext!)
        return profile
        

    }
    
    /// Creates activity with name "Morning shower" with built in timing
    ///
    /// - Duration: 30 min
    /// - Time to save: 10 min
    /// - Start time: 10:15 AM
    /// - Finish time: 10:45 AM
    open func fakeActivityWithProfile(_ profile: Profile, type: ActivityType, basis: Basis) -> Activity {
        let fakeActivity = Activity.createActivityWithType(type,
            name: "Morning shower",
            selectedDays: Basis.daysFromBasis(basis),
            startTime: StaticDateFormatter.shortDateAndTimeFormatter.date(from: "7/3/15, 10:15 AM")!,
            duration: ActivityDuration(value: 30, period: .minutes),
            notifications: true,
            timeToSave: 10,
            forProfile: profile)
        
        let busyDays = Weekday.weekdaysForBasis(basis)
        let days = NSMutableSet()
        for day in busyDays {
            days.add(Day.createFromWeekday(day, forActivity: fakeActivity)!)
        }
        fakeActivity.days = days.copy() as! NSSet
    
        return fakeActivity
    }
    
    open func fakeTimingForActivity(_ activity: Activity) -> Timing {
        let newTiming = Timing.newTimingForActivity(activity: activity)
        newTiming.startTime = shortStyleDateFormatter().date(from: "7/3/15, 10:15 AM")!
        newTiming.finishTime = shortStyleDateFormatter().date(from: "7/3/15, 10:45 AM")!
        newTiming.duration = ActivityDuration(value: 30, period: .minutes)
        newTiming.timeToSave = NSNumber(value: 10.0 as Double)
        newTiming.activity = activity
        return newTiming
    }
    
    /// Saved 7 min
    open func fakeResultForActivity(_ activity: Activity) -> DayResults {
        let newResult = DayResults.newResultWithDate(Date(), forActivity: activity)
        newResult.date = DayResults.standardDateFormatter().string(from: Date())
        newResult.factFinishTime = activity.updatedFinishTime().addingTimeInterval(-5*60)
        newResult.activity.timing.manuallyStarted = activity.updatedStartTime().addingTimeInterval(2*60)
        newResult.factStartTime = (newResult.activity.timing.manuallyStarted!)
        newResult.factSuccess = NSNumber(value: newResult.daySuccessForTiming(activity.timing) as Double)
        
        newResult.factDuration = NSNumber(value: abs(newResult.factFinishTime.timeIntervalSince(newResult.factStartTime) / 60) as Double)
        
        if activity.isRoutine() {
            newResult.factSavedTime = NSNumber(value: Double(activity.timing.duration.value) - newResult.factDuration.doubleValue as Double)
        }
        
        newResult.activity.timing.manuallyStarted = nil
        return newResult
    }
    
    
    /// Converts dates with format: "7/3/15, 10:15 AM"
    open func shortStyleDateFormatter() -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        return dateFormatter
    }
}
