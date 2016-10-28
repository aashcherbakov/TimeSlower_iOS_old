//
//  NotificationFactory.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 10/15/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation
import UserNotifications
import TimeSlowerKit

internal enum NotificationType {
    case Start
    case Finish
}

internal struct NotificationFactory {
    
    func notifications(ofType type: NotificationType, forActivity activity: Activity) -> [LocalNotification] {
        switch type {
        case .Start: return startNotifications(forActivity: activity)
        case .Finish: return [FinishNotification(withActivity: activity)]
        }
    }
    
    func notificationRequests(forType type: NotificationType, activity: Activity) -> [UNNotificationRequest] {
        
        let notifications = self.notifications(ofType: type, forActivity: activity)
        let requests = notifications.map { (notification) -> UNNotificationRequest in
            return notification.request
        }
        return requests
    }
    
    private func notificationRequest(forNotification notification: LocalNotification, identifier: String, category: String) -> UNNotificationRequest {
        let trigger = notification.notificationTrigger(forDate: notification.date(), repeats: notification.repeats, type: notification.type)
        print(trigger)
        let content = contentForNotification(notification: notification, category: category)
        print(content)
        return UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
    }
    
    private func contentForNotification(notification: LocalNotification, category: String) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = notification.title()
        content.body = notification.body()
        content.sound = UNNotificationSound.default()
        content.categoryIdentifier = category
        
        return content
    }

    
    // MARK: - Private Functions

    private func startNotifications(forActivity activity: Activity) -> [StartNotification] {
        var notifications = [StartNotification]()
        for weekday in activity.days {
            let notification = StartNotification(withActivity: activity, weekday: weekday)
            notifications.append(notification)
        }
        
        return notifications
    }
}
