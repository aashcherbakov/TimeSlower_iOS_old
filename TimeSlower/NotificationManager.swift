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

public extension Activity {
    
    struct Constants {
        static let identifierForCommonGoalNotif = "Common Notification For Goals"
    }
    
    //MARK: - Create notifications
    
    public func scheduleDefaultStartNotification() {
        
        deleteScheduledNotificationsForCurrentActivity()
        
        switch activityBasis() {
        case .daily: createNotificationOnDailyBasis()
        case .workdays: createNotificationOnWorkdayBasis()
        case .weekends: createNotificationOnWeekendBasis()
        default: return
        }
    }
    
    func scheduleFinishTimerNotification() {
        let notification = localNotificationForCategory(.FinishTimer)
        UIApplication.shared.scheduleLocalNotification(notification)
        
        scheduleRestorationTimer()
    }
    
    func scheduleLastCallTimerNotification() {
        let notification = localNotificationForCategory(.LastCallTimer)
        UIApplication.shared.scheduleLocalNotification(notification)
        
        scheduleRestorationTimer()
    }
    
    func scheduleRemindMeInNotification(_ timeInterval: Int) {
        let notification = localNotificationForCategory(.StartTimer)
        notification.fireDate = Date().addingTimeInterval(TimeInterval(timeInterval * 60))
        UIApplication.shared.scheduleLocalNotification(notification)
    }
    
    
    //MARK: - StartTimer category by basis
    func createNotificationOnDailyBasis() {
        let dailyNotification = localNotificationForCategory(.StartTimer)
        dailyNotification.repeatInterval = .day
        UIApplication.shared.scheduleLocalNotification(dailyNotification)
    }
    
    func createNotificationOnWorkdayBasis() {
        let calendar = Calendar.current
        let firstWorkdayAlarm = firstAlarmOfWorkWeek()
        var componentsToAdd = (calendar as NSCalendar).components(.weekday, from: firstWorkdayAlarm)
        for i in 0...4 {
            componentsToAdd.weekday = i
            let fireDate = (calendar as NSCalendar).date(byAdding: componentsToAdd, to: firstWorkdayAlarm, options: [])
            
            let workdaysNotification = localNotificationForCategory(.StartTimer)
            workdaysNotification.fireDate = fireDate
            workdaysNotification.repeatInterval = .weekday
            UIApplication.shared.scheduleLocalNotification(workdaysNotification)
        }
    }
    
    func createNotificationOnWeekendBasis() {
        let calendar = Calendar.current
        let alarmDayNumber = (calendar as NSCalendar).component(.weekday, from: updatedAlarmTime())
        let weekendDayNumbers = [1, 7]
        for i in 0...1 {
            let difference = alarmDayNumber - weekendDayNumbers[i]
            var componentsToAdd = DateComponents()
            componentsToAdd.weekday = -difference
            let fireDate = (calendar as NSCalendar).date(byAdding: componentsToAdd, to: updatedAlarmTime(), options: [])
            
            let weekendNotification = localNotificationForCategory(.StartTimer)
            weekendNotification.fireDate = fireDate
            weekendNotification.repeatInterval = .weekday
            UIApplication.shared.scheduleLocalNotification(weekendNotification)
        }
    }
    
    func firstAlarmOfWorkWeek() -> Date {
        let calendar = Calendar.current
        var components = DateComponents()
        let difference = (calendar.firstWeekday + 1) - (calendar as NSCalendar).component(.weekday, from: updatedAlarmTime())
        components.weekday = difference
        return (calendar as NSCalendar).date(byAdding: components, to: updatedAlarmTime(), options: [])!
    }
    
    
    //MARK: - UILocalNotification instance
    func localNotificationForCategory(_ category: TimerCategory) -> UILocalNotification {
        let notification = UILocalNotification()
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.category = category.rawValue
        notification.alertBody = messageForCategory(category)
        notification.alertTitle = name
        
        notification.fireDate = fireDateForCategory(category)
        notification.userInfo =
                ["activityName" : notification.alertTitle!,
                    "message" : notification.alertBody!]
        
        
        return notification
    }
    
    func messageForCategory(_ category: TimerCategory) -> String {
        switch category {
        case .StartTimer: return startTimerNotificationMessage()
        case .FinishTimer: return finishTimeNotificationMessage()
        case .LastCallTimer: return lastCallNotificationMessage()
        }
    }
    
    func fireDateForCategory(_ category: TimerCategory) -> Date {
        switch category {
        case .StartTimer: return updatedStartTime()
        case .FinishTimer: return updatedAlarmTime()
        case .LastCallTimer: return updatedFinishTime()
        }
    }
    
    //MARK: - In case user did not tap "Finish now" on lastStand notification
    func scheduleRestorationTimer() {
        let intervalTillNextAction = timing.timeIntervalTillRegularEndOfActivity() + 120.0
        Foundation.Timer.scheduledTimer(timeInterval: intervalTillNextAction, target: self, selector: #selector(Activity.forceFinishActivityInCaseUserHasForgotten), userInfo: nil, repeats: false)
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
                        UIApplication.shared.cancelLocalNotification(notification)
                    }
                }
            }
        }
    }
    
    func deleteScheduledNotificationsForCurrentActivity() {
        for notification in allNotifications()! {
            if let name = notification.userInfo?["activityName"] as? String {
                if name == self.name {
                    UIApplication.shared.cancelLocalNotification(notification)
                }
            }
        }
    }
    
    func allNotifications() -> [UILocalNotification]? {
        return UIApplication.shared.scheduledLocalNotifications
    }
}
