//
//  LocalNotificationProtocol.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 10/23/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation
import TimeSlowerKit
import UserNotifications

internal protocol LocalNotification {
    
    var activity: Activity { get }
    var repeats: Bool { get }
    var type: NotificationType { get }
    
    var categoryIdentifier: NotificationCategory { get }
    
    func identifier() -> String
    func title() -> String
    func body() -> String
    func date() -> Date
    func userInfo() -> [AnyHashable : Any]
    
    var request: UNNotificationRequest { get }
    
    func notificationTrigger(forDate date: Date, repeats: Bool, type: NotificationType) -> UNNotificationTrigger
    
}

extension LocalNotification {
    func userInfo() -> [AnyHashable : Any] {
        return [ kActivityResourceId : activity.resourceId ]
    }
    
    var categoryIdentifier: NotificationCategory {
        get {
            return NotificationCategory(withNotificationType: self.type)
        }
    }
    
    var request: UNNotificationRequest {
        get {
            let trigger = notificationTrigger(forDate: self.date(), repeats: self.repeats, type: self.type)
            let content = contentForNotification()
            return UNNotificationRequest(identifier: identifier(), content: content, trigger: trigger)
        }
    }
    
    private func contentForNotification() -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = self.title()
        content.body = self.body()
        content.sound = UNNotificationSound.default()
        content.categoryIdentifier = self.categoryIdentifier.rawValue
        return content
    }
}
