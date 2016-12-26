//
//  FinishNotification.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 10/23/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation
import TimeSlowerKit
import UserNotifications

internal struct FinishNotification: LocalNotification {
    
    let type = NotificationType.Finish
    let activity: Activity
    let repeats = false
    
    init(withActivity activity: Activity) {
        self.activity = activity
    }
    
    func title() -> String {
        return "Time to finish \(activity.name)!"
    }
    
    func body() -> String {
        let time = String(format: "%.0f", activity.estimates.sumMonths)
        return "If you finish now, you will save \(time) months of your life 🙄"
    }
    
    func date() -> Date {
        return activity.alarmTime()
    }
    
    func identifier() -> String {
        return "\(activity.resourceId)+finish"
    }
    
    func notificationTrigger(forDate date: Date, repeats: Bool, type: NotificationType) -> UNNotificationTrigger {
        let interval = date.timeIntervalSinceNow
        return UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: repeats)
    }
    
}
