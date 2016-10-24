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
    
    private func startNotifications(forActivity activity: Activity) -> [StartNotification] {
        var notifications = [StartNotification]()
        for weekday in activity.days {
            let notification = StartNotification(withActivity: activity, weekday: weekday)
            notifications.append(notification)
        }
        
        return notifications
    }
}
