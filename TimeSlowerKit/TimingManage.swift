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
    
    public class func newTimingForActivity(activity givenActivity: Activity) -> Timing {
        let entity = NSEntityDescription.entityForName("Timing", inManagedObjectContext: givenActivity.managedObjectContext!)
        let timing = Timing(entity: entity!, insertIntoManagedObjectContext: givenActivity.managedObjectContext)
        timing.activity = givenActivity
        
        var error: NSError?
        do {
            try givenActivity.managedObjectContext!.save()
        } catch let error1 as NSError { error = error1; print("Could not save: \(error)") }
        
        return timing
    }
    
    public func updateDuration() {
        var totalDuration = finishTime.timeIntervalSinceDate(startTime) / 60.0
        if totalDuration < 0 {
            totalDuration = totalDuration * -1
        }
        duration = NSNumber(double: totalDuration)
    }
    
    public func updateAlarmTime() {
        alarmTime = updatedAlarmTime()
    }
    
    public func isPassedDueForToday() -> Bool {
        let nowDate = NSDate(), finishTime = updatedFinishTime()
        let earlierDate = nowDate.earlierDate(finishTime)
        return (earlierDate == finishTime) ? true : false
    }
    
    public func isGoingNow() -> Bool {
        let startTime = updatedStartTime(), finishTime = updatedFinishTime()
        if finishTime < NSDate() {
            return false
        } else if isDoneForToday() {
            return false
        }
        
        
        if startTime == startTime.earlierDate(NSDate()) && finishTime == finishTime.laterDate(NSDate()) {
            return true
        }
        return false
    }
    
    public func isDoneForToday() -> Bool {
        if let _ = DayResults.fetchResultWithDate(NSDate(), forActivity: self.activity) {
            return true
        }
        return false
    }
    
    
    //MARK: - Timing of activity
    
    public func updatedStartTime() -> NSDate {
        return (manuallyStarted != nil) ? manuallyStarted! : Timing.updateTimeForToday(startTime)
    }
    
    public func updatedFinishTime() -> NSDate {
        var newTime: NSDate?
        if let userStarted = manuallyStarted {
            newTime = NSDate(timeInterval: duration.doubleValue * 60, sinceDate: userStarted)
        } else {
            newTime = Timing.updateTimeForToday(finishTime)
            if finishTimeIsNextDay() {
                newTime = newTime?.dateByAddingTimeInterval(60*60*24)
            }
        }
        return newTime!
    }
    
    public func finishTimeIsNextDay() -> Bool {
        
        let calendar = NSCalendar.currentCalendar()
        calendar.timeZone = NSTimeZone.localTimeZone()
        let startTimeDayComponent = calendar.components(.Day, fromDate: startTime)
        let dateAfterAddingActivityDuration = startTime.dateByAddingTimeInterval(duration.doubleValue * 60)
        let finishTimeDayComponent = calendar.components(.Day, fromDate: dateAfterAddingActivityDuration)
        return (startTimeDayComponent.day == finishTimeDayComponent.day) ? false : true
    }
    
    
    // Based on assumption that alarm time for routine is only one - for saving time
    public func updatedAlarmTime() -> NSDate {
        let timeIntervalForRoutineAlarm = (duration.doubleValue - timeToSave.doubleValue) * 60
        var sinceDate = startTime
        if let manuallyStarted = manuallyStarted {
            sinceDate = manuallyStarted
        }
        let alarmForRoutine = NSDate(timeInterval: timeIntervalForRoutineAlarm, sinceDate: sinceDate)
        return (activity.isRoutine()) ? alarmForRoutine : updatedFinishTime()
    }
    
    public class func updateTimeForToday(oldTime: NSDate) -> NSDate {
        let oldDateComponents = NSCalendar.currentCalendar().components([.Hour, .Minute], fromDate: oldTime)
        let newDateComponents = NSCalendar.currentCalendar().components([.Month, .Day, .Year], fromDate: NSDate())
        let finalComponents = NSDateComponents()
        finalComponents.year = newDateComponents.year
        finalComponents.month = newDateComponents.month
        finalComponents.day = newDateComponents.day
        finalComponents.hour = oldDateComponents.hour
        finalComponents.minute = oldDateComponents.minute
        
        let newDate = NSCalendar.currentCalendar().dateFromComponents(finalComponents)!
        return newDate
    }
    
    public func nextActionTime() -> NSDate {
        if activity.isDoneForToday() || activity.isPassedDueForToday() {
            return nextActionDate()
        } else {
            return updatedStartTime() < (NSDate()) ? updatedFinishTime() : updatedStartTime()
        }
    }
    
    public func nextActionDate() -> NSDate {
        switch activity.activityBasis() {
        case .Daily: return nextDayFromStartTime()
        case .Weekends: return nextWeekendDayFromDate(NSDate())
        case .Workdays: return nextWorkdayFromDate(NSDate())
        }
    }
    
    public func nextWeekendDayFromDate(date: NSDate) -> NSDate {
        let dayName = LazyCalendar.dayNameForDate(date)
        if dayName == .Saturday {
            return nextDayFromStartTime()
        } else {
            return LazyCalendar.nextDayWithName(.Saturday, fromDate: date)
        }
    }
    
    public func nextWorkdayFromDate(date: NSDate) -> NSDate {
        let dayName = LazyCalendar.dayNameForDate(date)
        if dayName == .Friday || dayName == .Saturday {
            return LazyCalendar.nextDayWithName(.Monday, fromDate: date)
        } else {
            return nextDayFromStartTime()
        }
    }
    
    
    public func timeIntervalTillRegularEndOfActivity() -> NSTimeInterval {
        return Timing.updateTimeForToday(finishTime).timeIntervalSinceNow
    }
    
    
    func nextDayFromStartTime() -> NSDate {
        return NSDate(timeInterval: 60*60*24, sinceDate: updatedStartTime())
    }
    
    
    
    
    
    
    
}
