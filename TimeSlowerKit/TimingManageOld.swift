////
////  TimingManage.swift
////  TimeSlower2
////
////  Created by Aleksander Shcherbakov on 5/3/15.
////  Copyright (c) 2015 1lastDay. All rights reserved.
////
//
//import Foundation
//import CoreData
//
//extension Timing {
//    
//    public class func newTimingForActivity(activity givenActivity: Activity) -> Timing {
//        let entity = NSEntityDescription.entity(forEntityName: "Timing", in: givenActivity.managedObjectContext!)
//        let timing = Timing(entity: entity!, insertInto: givenActivity.managedObjectContext)
//        timing.activity = givenActivity
//        
//        var error: NSError?
//        do {
//            try givenActivity.managedObjectContext!.save()
//        } catch let error1 as NSError { error = error1; print("Could not save: \(error)") }
//        
//        return timing
//    }
//    
//    public func updateAlarmTime() {
//        alarmTime = updatedAlarmTime()
//    }
//    
//    public func isPassedDueForToday() -> Bool {
//        let nowDate = Date(), finishTime = updatedFinishTime()
//        let earlierDate = (nowDate as NSDate).earlierDate(finishTime)
//        return (earlierDate == finishTime) ? true : false
//    }
//    
//    public func isGoingNow() -> Bool {
//        let startTime = updatedStartTime(), finishTime = updatedFinishTime()
//        if finishTime < Date() {
//            return false
//        } else if isDoneForToday() {
//            return false
//        }
//        
//        
//        if startTime == (startTime as NSDate).earlierDate(Date()) && finishTime == (finishTime as NSDate).laterDate(Date()) {
//            return true
//        }
//        return false
//    }
//    
//    public func isDoneForToday() -> Bool {
//        if let _ = DayResults.fetchResultWithDate(Date(), forActivity: self.activity) {
//            return true
//        }
//        return false
//    }
//    
//    
//    //MARK: - Timing of activity
//    
//    public func updatedStartTime() -> Date {
//        return (manuallyStarted != nil) ? manuallyStarted! as Date : Timing.updateTimeForToday(startTime as Date)
//    }
//    
//    /**
//     Updates startTime of activity to given date. 
//     Use cases:
//     1) When activity is created, it has only time, not date (DatePicker displays only time)
//     2) When we look when activity should accure next in calendar
//     
//     - parameter date: NSDate to which startTime should be updated
//     
//     - returns: NSDate with correct start time in specified date
//     */
//    public func updatedStartTimeForDate(_ date: Date) -> Date {
//        if let manuallyStarted = manuallyStarted {
//            return manuallyStarted as Date
//        } else {
//            return TimeMachine().updatedTime(startTime, forDate: date)
//        }
//    }
//    
//    public func updatedFinishTime() -> Date {
//        var newTime: Date?
//        if let userStarted = manuallyStarted {
//            newTime = Date(timeInterval: Double(duration.minutes()) * 60, since: userStarted as Date)
//        } else {
//            newTime = Timing.updateTimeForToday(finishTime as Date)
//            if finishTimeIsNextDay() {
//                newTime = newTime?.addingTimeInterval(60*60*24)
//            }
//        }
//        return newTime!
//    }
//    
//    public func finishTimeIsNextDay() -> Bool {
//        
//        var calendar = Calendar.current
//        calendar.timeZone = TimeZone.autoupdatingCurrent
//        let startTimeDayComponent = (calendar as NSCalendar).components(.day, from: startTime as Date)
//        let dateAfterAddingActivityDuration = startTime.addingTimeInterval(Double(duration.minutes()) * 60)
//        let finishTimeDayComponent = (calendar as NSCalendar).components(.day, from: dateAfterAddingActivityDuration as Date)
//        return (startTimeDayComponent.day == finishTimeDayComponent.day) ? false : true
//    }
//    
//    
//    // Based on assumption that alarm time for routine is only one - for saving time
//    public func updatedAlarmTime() -> Date {
//        let timeIntervalForRoutineAlarm = (duration.minutes() - timeToSave.intValue) * 60
//        var sinceDate = startTime
//        if let manuallyStarted = manuallyStarted {
//            sinceDate = manuallyStarted
//        }
//        let alarmForRoutine = Date(timeInterval: Double(timeIntervalForRoutineAlarm), since: sinceDate as Date)
//        return (activity.isRoutine()) ? alarmForRoutine : updatedFinishTime()
//    }
//    
//    public class func updateTimeForToday(_ oldTime: Date) -> Date {
//        let oldDateComponents = (Calendar.current as NSCalendar).components([.hour, .minute], from: oldTime)
//        let newDateComponents = (Calendar.current as NSCalendar).components([.month, .day, .year], from: Date())
//        var finalComponents = DateComponents()
//        finalComponents.year = newDateComponents.year
//        finalComponents.month = newDateComponents.month
//        finalComponents.day = newDateComponents.day
//        finalComponents.hour = oldDateComponents.hour
//        finalComponents.minute = oldDateComponents.minute
//        
//        let newDate = Calendar.current.date(from: finalComponents)!
//        return newDate
//    }
//
//    
//    public func nextActionTime() -> Date {
//        if activity.isDoneForToday() || activity.isPassedDueForToday() {
//            return nextActionDate()
//        } else {
//            return updatedStartTime() < (Date()) ? updatedFinishTime() : updatedStartTime()
//        }
//    }
//    
//    /**
//     Next date in activity schedule
//     
//     - returns: NSDate
//     */
//    public func nextActionDate() -> Date {
//        guard let days = activity.days as? Set<Day> else {
//            fatalError("Activity store non-Day type in .days property")
//        }
//        
//        let currentWeekday = Weekday.createFromDate(Date())
//        let busyWeekdays = Weekday.weekdaysFromSetOfDays(days)
//        let nextClosestDay = Weekday.closestDay(busyWeekdays, toDay: currentWeekday)
//        let nextDate = TimeMachine().nextOccuranceOfWeekday(nextClosestDay, fromDate: Date())
//        let actionTimeInDate = activityStartTime(startTime, inDate: nextDate)
//        return actionTimeInDate
//    }
//    
//    /**
//     Merges given start time's time in a day and next date's day, month and year
//     
//     - parameter startTime: NSDate for activity start time
//     - parameter nextDate:  NSDate where activity should fire next
//     
//     - returns: NSDate of start time
//     */
//    public func activityStartTime(_ startTime: Date, inDate nextDate: Date) -> Date {
//        let startTimeComponents = (Calendar.current as NSCalendar).components([.minute, .hour], from: startTime)
//        var nextDateComponents = (Calendar.current as NSCalendar).components([.day, .month, .year, .minute, .hour], from: nextDate)
//        nextDateComponents.hour = startTimeComponents.hour
//        nextDateComponents.minute = startTimeComponents.minute
//        return Calendar.current.date(from: nextDateComponents)!
//    }
//    
//    
//    public func timeIntervalTillRegularEndOfActivity() -> TimeInterval {
//        return Timing.updateTimeForToday(finishTime as Date).timeIntervalSinceNow
//    }
//    
//    
//    func nextDayFromStartTime() -> Date {
//        return Date(timeInterval: 60*60*24, since: updatedStartTime())
//    }
//}
