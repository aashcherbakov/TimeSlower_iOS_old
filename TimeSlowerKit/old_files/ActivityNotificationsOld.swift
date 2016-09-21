////
////  ActivityNotifications.swift
////  TimeSlower2
////
////  Created by Aleksander Shcherbakov on 5/3/15.
////  Copyright (c) 2015 1lastDay. All rights reserved.
////
//
//import Foundation
//import UIKit
//
//extension Activity {
//    
//    struct Constants {
//        static let identifierForCommonGoalNotif = "Common Notification For Goals"
//    }
//    
////    //MARK: - Create notifications
////    
////    func scheduleCommonNotificationForGoals() {
////        var notification = UILocalNotification()
////        let components = NSDateComponents()
////        components.hour = 22
////        notification.fireDate = NSCalendar.currentCalendar().dateFromComponents(components)
////        notification.repeatInterval = .CalendarUnitDay
////        notification.soundName = UILocalNotificationDefaultSoundName
////        notification.alertBody = "Time to check on tofay's goals!"
////        notification.userInfo = userInfoForCommonGoalsNotification()
////        UIApplication.sharedApplication().scheduleLocalNotification(notification)
////    }
////    
////    func scheduleSnoozeNotificationForActivity() {
////        if !isDoneForToday() {
////            let notification = standardNotification()
////            notification.fireDate = updatedFinishTime()
////            notification.alertBody = "Time's up!"
////            UIApplication.sharedApplication().scheduleLocalNotification(notification)
////        }
////    }
////    
////    func scheduleLocalNotificationForActivity() {
////        switch activityBasis() {
////        case .Daily: createNotificationOnDailyBasis()
////        case .Workdays: createNotificationOnWorkdayBasis()
////        case .Weekends: createNotificationOnWeekendBasis()
////        }
////    }
////    
////    func createNotificationOnDailyBasis() {
////        let dailyAlert = standardNotification()
////        dailyAlert.repeatInterval = .CalendarUnitDay
////        UIApplication.sharedApplication().scheduleLocalNotification(dailyAlert)
////    }
////    
////    func createNotificationOnWorkdayBasis() {
////        let calendar = NSCalendar.currentCalendar()
////        let firstWorkdayAlarm = firstAlarmOfWorkWeek()
////        var componentsToAdd = calendar.components(.CalendarUnitWeekday, fromDate: firstWorkdayAlarm)
////        for i in 0...4 {
////            componentsToAdd.weekday = i
////            let fireDate = calendar.dateByAddingComponents(componentsToAdd, toDate: firstWorkdayAlarm, options: nil)
////            
////            let workdaysNotification = standardNotification()
////            workdaysNotification.fireDate = fireDate
////            workdaysNotification.repeatInterval = .CalendarUnitWeekday
////            UIApplication.sharedApplication().scheduleLocalNotification(workdaysNotification)
////        }
////    }
////    
////    func createNotificationOnWeekendBasis() {
////        let calendar = NSCalendar.currentCalendar()
////        let alarmDayNumber = calendar.component(.CalendarUnitWeekday, fromDate: updatedAlarmTime())
////        let weekendDayNumbers = [1, 7]
////        for i in 0...1 {
////            let difference = alarmDayNumber - weekendDayNumbers[i]
////            let componentsToAdd = NSDateComponents()
////            componentsToAdd.weekday = -difference
////            let fireDate = calendar.dateByAddingComponents(componentsToAdd, toDate: updatedAlarmTime(), options: nil)
////            
////            let weekendNotification = standardNotification()
////            weekendNotification.fireDate = fireDate
////            weekendNotification.repeatInterval = .CalendarUnitWeekday
////            UIApplication.sharedApplication().scheduleLocalNotification(weekendNotification)
////        }
////    }
////    
////    func standardNotification() -> UILocalNotification {
////        let notification = UILocalNotification()
////        notification.userInfo = userInfoForActivity()
////        notification.alertBody = alertBodyForNotification()
////        notification.fireDate = updatedAlarmTime()
////        notification.soundName = UILocalNotificationDefaultSoundName
////        if isRoutine() { notification.alertAction = "I'm done!" }
////        return notification
////    }
////    
////    func alertBodyForNotification() -> String {
////        let messageForRoutine = "Time to finish \(name)"
////        let messageForGoal = "Time to start \(name)"
////        return (isRoutine()) ? messageForRoutine : messageForGoal
////    }
////    
////    func firstAlarmOfWorkWeek() -> NSDate {
////        let calendar = NSCalendar.currentCalendar()
////        let components = NSDateComponents()
////        let difference = (calendar.firstWeekday + 1) - calendar.component(.CalendarUnitWeekday, fromDate: updatedAlarmTime())
////        components.weekday = difference
////        
////        return calendar.dateByAddingComponents(components, toDate: updatedAlarmTime(), options: nil)!
////    }
////    
////    func userInfoForCommonGoalsNotification() -> [NSObject : AnyObject] {
////        return ["Name" : Constants.identifierForCommonGoalNotif]
////    }
////    
////    //MARK: - Update notifications
////    
////    func updateNotificationForToday() {
////        deleteNotificationForCurrentDay()
////        createNotificationIfStartedManually()
////    }
////    
////    func createNotificationIfStartedManually() {
////        let rushNotification = standardNotification()
////        UIApplication.sharedApplication().scheduleLocalNotification(rushNotification)
////        scheduleRestorationTimer()
////    }
////    
////    func scheduleRestorationTimer() {
////        let intervalTillNextAction = timing.timeIntervalTillRegularEndOfActivity()! + 120.0
////        NSTimer.scheduledTimerWithTimeInterval(intervalTillNextAction, target: self, selector: "restoreRegularNotifications", userInfo: nil, repeats: false)
////    }
////    
////    func restoreRegularNotifications() {
////        deleteScheduledNotificationsForCurrentActivity()
////        scheduleLocalNotificationForActivity()
////    }
////    
////    //MARK: - Delete notifications
////    
////    func deleteNotificationForCurrentDay() {
////        let allNotifications = UIApplication.sharedApplication().scheduledLocalNotifications as! [UILocalNotification]
////        for notification in allNotifications {
////            if let name = notification.userInfo?["Name"] as? String {
////                if name == self.name {
////                    let calendar = NSCalendar.currentCalendar()
////                    let units = NSCalendarUnit.CalendarUnitDay | NSCalendarUnit.CalendarUnitMonth
////                    let fireDateComponents = calendar.components(units, fromDate: notification.fireDate!)
////                    let todayComponents = calendar.components(units, fromDate: NSDate())
////                    if fireDateComponents.day == todayComponents.day &&
////                        fireDateComponents.month == todayComponents.month {
////                        UIApplication.sharedApplication().cancelLocalNotification(notification)
////                    }
////                }
////            }
////        }
////    }
////    
////    func deleteScheduledNotificationsForCurrentActivity() {
////        let allNotifications = UIApplication.sharedApplication().scheduledLocalNotifications as! [UILocalNotification]
////        for notification in allNotifications {
////            if let name = notification.userInfo?["Name"] as? String {
////                if name == self.name {
////                    UIApplication.sharedApplication().cancelLocalNotification(notification)
////                }
////            }
////        }
////    }
////    
////    func deleteCommonNightNotificationForGoals() {
////        if !isRoutine() {
////            if !profile.hasGoals() {
////                let allNotifications = UIApplication.sharedApplication().scheduledLocalNotifications as! [UILocalNotification]
////                for notification in allNotifications {
////                    if let name = notification.userInfo?["Name"] as? String {
////                        if name == Constants.identifierForCommonGoalNotif {
////                            UIApplication.sharedApplication().cancelLocalNotification(notification)
////                        }
////                    }
////                }
////            }
////        }
////    }
//}
