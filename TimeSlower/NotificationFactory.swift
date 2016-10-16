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

internal protocol LocalNotification {
    var activity: Activity { get }
    var repeats: Bool { get }
    
    func title() -> String
    func body() -> String
    func date() -> Date
    func userInfo() -> [AnyHashable : Any]
    init(withActivity activity: Activity)
}

extension LocalNotification {
    func userInfo() -> [AnyHashable : Any] {
        return [ kActivityResourceId : activity.resourceId ]
    }
}

internal struct NotificationFactory {
    
    func notificarion(ofType type: NotificationType, forActivity activity: Activity) -> LocalNotification {
        switch type {
        case .Start: return StartNotification(withActivity: activity)
        case .Finish: return FinishNotification(withActivity: activity)
        }
    }
    
}

internal struct StartNotification: LocalNotification {
    
    let activity: Activity
    let repeats = false
    
    init(withActivity activity: Activity) {
        self.activity = activity
    }
    
    func title() -> String {
        return "Time to start \(activity.name)!"
    }
    
    func body() -> String {
        return "Remember, you wanted to spend \(activity.timeToSave()) less on it today"
    }
    
    func date() -> Date {
        return activity.nextActionTime()
    }
    
}

internal struct FinishNotification: LocalNotification {
    
    let activity: Activity
    let repeats = true

    init(withActivity activity: Activity) {
        self.activity = activity
    }
    
    func title() -> String {
        return "Time to finish \(activity.name)!"
    }
    
    func body() -> String {
        return "If you finish now, you will save \(activity.stats.summMonths) months of your life 🙄"
    }
    
    func date() -> Date {
        return activity.alarmTime()
    }
    
}

