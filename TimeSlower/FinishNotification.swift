//
//  FinishNotification.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 10/23/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation
import TimeSlowerKit

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
        let time = String(format: "%.1f", activity.stats.summMonths)
        return "If you finish now, you will save \(time) months of your life 🙄"
    }
    
    func date() -> Date {
        return activity.alarmTime()
    }
    
    func identifier() -> String {
        return "\(activity.resourceId)+finish"
    }
    
}
