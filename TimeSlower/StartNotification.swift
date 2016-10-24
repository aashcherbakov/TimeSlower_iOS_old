//
//  StartNotification.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 10/23/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation
import TimeSlowerKit

internal struct StartNotification: LocalNotification {
    
    let type = NotificationType.Start
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
        return "Remember, you wanted to spend \(activity.timeToSave()) less on it today"
    }
    
    func date() -> Date {
        return activity.startTime()
    }
    
    func identifier() -> String {
        return "\(activity.resourceId)+\(weekday.shortName)"
    }
    
}
