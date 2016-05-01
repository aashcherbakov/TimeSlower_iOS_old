//
//  NotificationManager.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 10/23/15.
//  Copyright © 2015 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation
import TimeSlowerKit

public let kStartNowButtonAction = "startNowButtonAction"
public let kFinishNowButtonAction = "finishNowButtonAction"
public let kRemindMeButtonAction = "remindMeButtonAction"
public let kSnoozeButtonAction = "snoozeButtonAction"

// Tasks from Watch to parent app
public enum AppTask: String {
    case ScheduleStartNotification = "scheduleStartNotification"
    case ScheduleFinishNotification = "scheduleFinishTimerNotificationTask"
    case ScheduleLastCallNotification = "scheduleLastCallNotificationTask"
    case DeleteNonStandardNotifications = "deleteNonStandardNotificationsTask"
}


public enum TimerCategory: String {
    case StartTimer = "startTimer"
    case FinishTimer = "finishTimer"
    case LastCallTimer = "lastCallTimer"
}

extension Activity {
    
    struct Constants {
        static let identifierForCommonGoalNotif = "Common Notification For Goals"
    }
    
    //MARK: - Create notifications
    
    func scheduleDefaultStartNotification() {
        
        deleteScheduledNotificationsForCurrentActivity()
        
        switch activityBasis() {
        case .Daily: createNotificationOnDailyBasis()
        case .Workdays: createNotificationOnWorkdayBasis()
        case .Weekends: createNotificationOnWeekendBasis()
        default: return
        }
    }
    
    func scheduleFinishTimerNotification() {
        let notification = localNotificationForCategory(.FinishTimer)
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        
        scheduleRestorationTimer()
    }
    
    func scheduleLastCallTimerNotification() {
        let notification = localNotificationForCategory(.LastCallTimer)
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        
        scheduleRestorationTimer()
    }
    
    func scheduleRemindMeInNotification(timeInterval timeInterval: Int) {
        let notification = localNotificationForCategory(.StartTimer)
        notification.fireDate = NSDate().dateByAddingTimeInterval(NSTimeInterval(timeInterval * 60))
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    
    //MARK: - StartTimer category by basis
    func createNotificationOnDailyBasis() {
        let dailyNotification = localNotificationForCategory(.StartTimer)
        dailyNotification.repeatInterval = .Day
        UIApplication.sharedApplication().scheduleLocalNotification(dailyNotification)
    }
    
    func createNotificationOnWorkdayBasis() {
        let calendar = NSCalendar.currentCalendar()
        let firstWorkdayAlarm = firstAlarmOfWorkWeek()
        let componentsToAdd = calendar.components(.Weekday, fromDate: firstWorkdayAlarm)
        for i in 0...4 {
            componentsToAdd.weekday = i
            let fireDate = calendar.dateByAddingComponents(componentsToAdd, toDate: firstWorkdayAlarm, options: [])
            
            let workdaysNotification = localNotificationForCategory(.StartTimer)
            workdaysNotification.fireDate = fireDate
            workdaysNotification.repeatInterval = .Weekday
            UIApplication.sharedApplication().scheduleLocalNotification(workdaysNotification)
        }
    }
    
    func createNotificationOnWeekendBasis() {
        let calendar = NSCalendar.currentCalendar()
        let alarmDayNumber = calendar.component(.Weekday, fromDate: updatedAlarmTime())
        let weekendDayNumbers = [1, 7]
        for i in 0...1 {
            let difference = alarmDayNumber - weekendDayNumbers[i]
            let componentsToAdd = NSDateComponents()
            componentsToAdd.weekday = -difference
            let fireDate = calendar.dateByAddingComponents(componentsToAdd, toDate: updatedAlarmTime(), options: [])
            
            let weekendNotification = localNotificationForCategory(.StartTimer)
            weekendNotification.fireDate = fireDate
            weekendNotification.repeatInterval = .Weekday
            UIApplication.sharedApplication().scheduleLocalNotification(weekendNotification)
        }
    }
    
    func firstAlarmOfWorkWeek() -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        let components = NSDateComponents()
        let difference = (calendar.firstWeekday + 1) - calendar.component(.Weekday, fromDate: updatedAlarmTime())
        components.weekday = difference
        return calendar.dateByAddingComponents(components, toDate: updatedAlarmTime(), options: [])!
    }
    
    
    //MARK: - UILocalNotification instance
    func localNotificationForCategory(category: TimerCategory) -> UILocalNotification {
        let notification = UILocalNotification()
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.category = category.rawValue
        notification.alertBody = messageForCategory(category)
        if #available(iOS 8.2, *) {
            notification.alertTitle = name
        } else {
            // Fallback on earlier versions
        }
        notification.fireDate = fireDateForCategory(category)
        if #available(iOS 8.2, *) {
            notification.userInfo =
                ["activityName" : notification.alertTitle!,
                    "message" : notification.alertBody!]
        } else {
            // Fallback on earlier versions
        }
        
        return notification
    }
    
    func messageForCategory(category: TimerCategory) -> String {
        switch category {
        case .StartTimer: return startTimerNotificationMessage()
        case .FinishTimer: return finishTimeNotificationMessage()
        case .LastCallTimer: return lastCallNotificationMessage()
        }
    }
    
    func fireDateForCategory(category: TimerCategory) -> NSDate {
        switch category {
        case .StartTimer: return updatedStartTime()
        case .FinishTimer: return updatedAlarmTime()
        case .LastCallTimer: return updatedFinishTime()
        }
    }
    
    //MARK: - In case user did not tap "Finish now" on lastStand notification
    func scheduleRestorationTimer() {
        let intervalTillNextAction = timing.timeIntervalTillRegularEndOfActivity() + 120.0
        NSTimer.scheduledTimerWithTimeInterval(intervalTillNextAction, target: self, selector: "forceFinishActivityInCaseUserHasForgotten", userInfo: nil, repeats: false)
    }
    
    func forceFinishActivityInCaseUserHasForgotten() {
        finishWithResult()
    }
    
    //MARK: - Delete notifications
    
    func deleteNonStandardNotifications() {
        for notification in allNotifications()! {
            if let name = notification.userInfo?["activityName"] as? String {
                if name == self.name {
                    if notification.category != TimerCategory.StartTimer.rawValue {
                        UIApplication.sharedApplication().cancelLocalNotification(notification)
                    }
                }
            }
        }
    }
    
    func deleteScheduledNotificationsForCurrentActivity() {
        for notification in allNotifications()! {
            if let name = notification.userInfo?["activityName"] as? String {
                if name == self.name {
                    UIApplication.sharedApplication().cancelLocalNotification(notification)
                }
            }
        }
    }
    
    func allNotifications() -> [UILocalNotification]? {
        return UIApplication.sharedApplication().scheduledLocalNotifications
    }
}