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
    
    /**
     Updates startTime of activity to given date. 
     Use cases:
     1) When activity is created, it has only time, not date (DatePicker displays only time)
     2) When we look when activity should accure next in calendar
     
     - parameter date: NSDate to which startTime should be updated
     
     - returns: NSDate with correct start time in specified date
     */
    public func updatedStartTimeForDate(date: NSDate) -> NSDate {
        if let manuallyStarted = manuallyStarted {
            return manuallyStarted
        } else {
            return TimeMachine().updatedTime(startTime, forDate: date)
        }
    }
    
    public func updatedFinishTime() -> NSDate {
        var newTime: NSDate?
        if let userStarted = manuallyStarted {
            newTime = NSDate(timeInterval: Double(duration.minutes()) * 60, sinceDate: userStarted)
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
        let dateAfterAddingActivityDuration = startTime.dateByAddingTimeInterval(Double(duration.minutes()) * 60)
        let finishTimeDayComponent = calendar.components(.Day, fromDate: dateAfterAddingActivityDuration)
        return (startTimeDayComponent.day == finishTimeDayComponent.day) ? false : true
    }
    
    
    // Based on assumption that alarm time for routine is only one - for saving time
    public func updatedAlarmTime() -> NSDate {
        let timeIntervalForRoutineAlarm = (duration.minutes() - timeToSave.integerValue) * 60
        var sinceDate = startTime
        if let manuallyStarted = manuallyStarted {
            sinceDate = manuallyStarted
        }
        let alarmForRoutine = NSDate(timeInterval: Double(timeIntervalForRoutineAlarm), sinceDate: sinceDate)
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
    
    /**
     Next date in activity schedule
     
     - returns: NSDate
     */
    public func nextActionDate() -> NSDate {
        guard let days = activity.days as? Set<Day> else {
            fatalError("Activity store non-Day type in .days property")
        }
        
        let currentWeekday = Weekday.createFromDate(NSDate())
        let busyWeekdays = Weekday.weekdaysFromSetOfDays(days)
        let nextClosestDay = Weekday.closestDay(busyWeekdays, toDay: currentWeekday)
        let nextDate = TimeMachine().nextOccuranceOfWeekday(nextClosestDay, fromDate: NSDate())
        let actionTimeInDate = activityStartTime(startTime, inDate: nextDate)
        return actionTimeInDate
    }
    
    /**
     Merges given start time's time in a day and next date's day, month and year
     
     - parameter startTime: NSDate for activity start time
     - parameter nextDate:  NSDate where activity should fire next
     
     - returns: NSDate of start time
     */
    public func activityStartTime(startTime: NSDate, inDate nextDate: NSDate) -> NSDate {
        let startTimeComponents = NSCalendar.currentCalendar().components([.Minute, .Hour], fromDate: startTime)
        let nextDateComponents = NSCalendar.currentCalendar().components([.Day, .Month, .Year, .Minute, .Hour], fromDate: nextDate)
        nextDateComponents.hour = startTimeComponents.hour
        nextDateComponents.minute = startTimeComponents.minute
        return NSCalendar.currentCalendar().dateFromComponents(nextDateComponents)!
    }
    
    
    public func timeIntervalTillRegularEndOfActivity() -> NSTimeInterval {
        return Timing.updateTimeForToday(finishTime).timeIntervalSinceNow
    }
    
    
    func nextDayFromStartTime() -> NSDate {
        return NSDate(timeInterval: 60*60*24, sinceDate: updatedStartTime())
    }
}
