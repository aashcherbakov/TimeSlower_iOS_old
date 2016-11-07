//
//  UserDefaultsStore.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 11/6/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation

let kDidScheduleLocalNotifications = "didScheduleLocalNotifications"

internal struct UserDefaultsStore {
    
    private let userDefaults = UserDefaults.standard
    
    func hasScheduledLocalNotifications() -> Bool {
        return userDefaults.bool(forKey: kDidScheduleLocalNotifications)
    }
    
    func setHasScheduledLocalNotifications(value: Bool) {
        userDefaults.set(value, forKey: kDidScheduleLocalNotifications)
        userDefaults.synchronize()
    }
    
}
