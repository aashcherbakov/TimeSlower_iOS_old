//
//  NotificationScheduler.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 10/15/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation
import UserNotifications
import TimeSlowerKit

internal struct NotificationScheduler {
    
    private let notificationCenter = UNUserNotificationCenter.current()
    private let responder = NotificationResponder()
    
    /// Schedules notification for activity of specified type
    ///
    /// - parameter activity:         Activity
    /// - parameter notificationType: NotificationType
    func scheduleForActivity(activity: Activity, notificationType: NotificationType) {
        
        let notification = NotificationFactory().notificarion(ofType: notificationType, forActivity: activity)
        let categoryIdentifier = responder.categoryIdentifierForType(notificationType: notificationType)
        let request = notificationRequest(forNotification: notification, identifier: "Test Notification", category: categoryIdentifier)
        
        notificationCenter.getNotificationSettings { (settings) in
            if settings.authorizationStatus != .authorized {
                self.askForPermissionAndAdd(request: request)
            } else {
                self.addRequest(request: request)
            }
        }
    }
    
    private func askForPermissionAndAdd(request: UNNotificationRequest) {
        requestUserPermission { (success) in
            if success {
                self.addRequest(request: request)
            } else {
                // TODO: prompt alert for user that app can't work without notifications
            }
        }
    }
    
    private func requestUserPermission(completion: @escaping (Bool) -> ()) {
        notificationCenter.requestAuthorization(options: [.alert, .sound]) { (success, error) in
            if let error = error {
                print("Uh oh! Error with notification scheduler: \(error)")
            }
            
            completion(success)
        }
    }
    
    private func addRequest(request: UNNotificationRequest) {
        notificationCenter.removeAllPendingNotificationRequests()
        notificationCenter.add(request) { (error) in
            if let error = error {
                print("Uh oh! Error with notification scheduler: \(error)")
            }
        }
    }
    
    private func notificationRequest(forNotification notification: LocalNotification, identifier: String, category: String) -> UNNotificationRequest {
        let trigger = notificationTrigger(forDate: notification.date(), repeats: notification.repeats, type: notification.type)
        print(trigger)
        let content = contentForNotification(notification: notification, category: category)
        print(content)
        return UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
    }
    
    
    private func notificationTrigger(forDate date: Date, repeats: Bool, type: NotificationType) -> UNNotificationTrigger {
        switch type {
        case .Start: return dateTrigger(forDate: date, repeats: repeats)
        case .Finish: return timeTrigger(forDate: date, repeats: repeats)
        }
    }
    
    private func dateTrigger(forDate date: Date, repeats: Bool) -> UNCalendarNotificationTrigger {
        let components = dateComponents(fromDate: date)
        print(components)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: repeats)
        return trigger
    }
    
    private func timeTrigger(forDate date: Date, repeats: Bool) -> UNTimeIntervalNotificationTrigger {
        let interval = date.timeIntervalSinceNow
        return UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: repeats)
    }
    
    private func contentForNotification(notification: LocalNotification, category: String) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = notification.title()
        content.body = notification.body()
        content.sound = UNNotificationSound.default()
        content.categoryIdentifier = category
        
        return content
    }
    
    private func dateComponents(fromDate date: Date) -> DateComponents {
        let calendar = Calendar.current
        let components = calendar.dateComponents(in: .current, from: date)
        return DateComponents(calendar: calendar, timeZone: components.timeZone, era: components.era, year: components.year, month: components.month, day: components.day, hour: components.hour, minute: components.minute, second: components.second, nanosecond: components.nanosecond, weekday: components.weekday, weekdayOrdinal: components.weekdayOrdinal, quarter: components.quarter, weekOfMonth: components.weekOfMonth, weekOfYear: components.weekOfYear, yearForWeekOfYear: components.yearForWeekOfYear)
        
    }
    
}
