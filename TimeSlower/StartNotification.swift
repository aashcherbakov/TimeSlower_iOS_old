//
//  StartNotification.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 10/23/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation
import TimeSlowerKit
import UserNotifications

internal struct StartNotification: LocalNotification {
    
    let type = NotificationType.start
    let activity: Activity
    let repeats = true
    let weekday: Weekday
    
    init(withActivity activity: Activity, weekday: Weekday) {
        self.activity = activity
        self.weekday = weekday
    }
    
    func title() -> String {
        return "Time to start \(activity.name)!"
    }
    
    func body() -> String {
        return "Remember, you wanted to spend \(activity.minutesToSave()) less on it today"
    }
    
    func date() -> Date {
        let nextOccurance = weekday.nextDate()
        return activity.startTime(inDate: nextOccurance)
    }
    
    func identifier() -> String {
        return "\(activity.resourceId)+\(weekday.shortName)"
    }
    
    func notificationTrigger(forDate date: Date, repeats: Bool, type: NotificationType) -> UNNotificationTrigger {        
        let components = dateComponents(fromDate: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: repeats)
        return trigger
    }
    
    private func dateComponents(fromDate date: Date) -> DateComponents {
        let calendar = Calendar.current
        let components = calendar.dateComponents(in: .current, from: date)
        return DateComponents(calendar: calendar, timeZone: components.timeZone, hour: components.hour, minute: components.minute, second: components.second, weekday: components.weekday)
    }
}
