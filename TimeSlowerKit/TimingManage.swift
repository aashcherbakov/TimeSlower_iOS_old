//
//  TimingManage.swift
//  TimeSlower2
//
//  Created by Aleksander Shcherbakov on 5/3/15.
//  Copyright (c) 2015 1lastDay. All rights reserved.
//

import Foundation
import CoreData

extension Timing {
    
    class func newTimingForActivity(activity givenActivity: Activity) -> Timing {
        let entity = NSEntityDescription.entityForName("Timing", inManagedObjectContext: givenActivity.managedObjectContext!)
        let timing = Timing(entity: entity!, insertIntoManagedObjectContext: givenActivity.managedObjectContext)
        timing.activity = givenActivity
        
        var error: NSError?
        if !givenActivity.managedObjectContext!.save(&error) { print("Could not save: \(error)") }
        print("New timing created: \(timing)")

        return timing
    }
    
    func updateDuration() {
        var totalDuration = finishTime.timeIntervalSinceDate(startTime) / 60.0
        if totalDuration < 0 {
            totalDuration = totalDuration * -1
        }
        duration = NSNumber(double: totalDuration)
    }
    
    func updateAlarmTime() {
        alarmTime = updatedAlarmTime()
    }
    
    
    //MARK: - Timing of activity
    
    func updatedStartTime() -> NSDate {
        return (manuallyStarted != nil) ? manuallyStarted! : updateTimeForToday(startTime)!
    }
    
    func updatedFinishTime() -> NSDate {
        var newTime: NSDate?
        if let userStarted = manuallyStarted {
            newTime = NSDate(timeInterval: duration.doubleValue * 60, sinceDate: userStarted)
        } else {
            newTime = updateTimeForToday(finishTime)
        }
        return newTime!
    }
    
    // Based on assumption that alarm time for routine is only one - for saving time
    func updatedAlarmTime() -> NSDate {
        let timeIntervalForRoutineAlarm = (duration.doubleValue - timeToSave.doubleValue) * 60
        let alarmForManuallyStarted = NSDate(timeInterval: timeIntervalForRoutineAlarm, sinceDate: manuallyStarted!)
        let alarmForRegulerRoutine = NSDate(timeInterval: timeIntervalForRoutineAlarm, sinceDate: startTime)
        
        let alarmForRoutine = (manuallyStarted != nil) ? alarmForManuallyStarted : alarmForRegulerRoutine
        return (activity.isRoutine()) ? alarmForRoutine : updatedStartTime()
    }
    
    func updateTimeForToday(oldTime: NSDate?) -> NSDate? {
        var updatedDate: NSDate?
        if let timeToUpdate = oldTime {
            let unitFlags: NSCalendarUnit = .CalendarUnitMonth | .CalendarUnitDay | .CalendarUnitYear
            let oldDate = NSCalendar.currentCalendar().components(unitFlags, fromDate: timeToUpdate)
            let nowDate = NSCalendar.currentCalendar().components(unitFlags, fromDate: NSDate())
            
            var componentsToAdd = NSDateComponents()
            componentsToAdd.setValue(nowDate.month - oldDate.month, forComponent: .CalendarUnitMonth)
            componentsToAdd.setValue(nowDate.day - oldDate.day, forComponent: .CalendarUnitDay)
            componentsToAdd.setValue(nowDate.year - oldDate.year, forComponent: .CalendarUnitYear)
            
            updatedDate = NSCalendar.currentCalendar().dateByAddingComponents(componentsToAdd, toDate: timeToUpdate, options: nil)
            
        } else { print("Error: updateTimeForToday: nil insted of NSDate") }
        
        return updatedDate
    }
    
    func nextActionTime() -> NSDate {
        var nextActionTime: NSDate!
        if activity.isDoneForToday() || activity.isPassedDueForToday() {
            nextActionTime = NSDate(timeInterval: 60*60*24, sinceDate: updatedStartTime())
        } else {
            let startTime = updatedStartTime()
            nextActionTime = (startTime.earlierDate(NSDate()) == startTime) ? updatedFinishTime() : updatedStartTime()
        }
        return nextActionTime!
    }
    
    func timeIntervalTillRegularEndOfActivity() -> NSTimeInterval? {
        if let regularFinishTime = updateTimeForToday(finishTime) {
            return regularFinishTime.timeIntervalSinceNow
        }
        return nil
    }
    
    func checkIfManuallyStartedToday() -> Bool {
        let todayDay = NSCalendar.currentCalendar().component(.CalendarUnitDay, fromDate: NSDate())
        let manuallyDay = NSCalendar.currentCalendar().component(.CalendarUnitDay, fromDate: manuallyStarted!)

        if todayDay != manuallyDay {
            forceFinishManuallyStartedActivity()
        }
        return true
    }
    
    func forceFinishManuallyStartedActivity() {        
        if manuallyStarted != nil {
            manuallyStarted = nil
        }
    }
    
    
    
    
    
    
    
    
    
    
}
