//
//  LocalNotificationProtocol.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 10/23/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation
import TimeSlowerKit

internal protocol LocalNotification {
    
    var activity: Activity { get }
    var repeats: Bool { get }
    var type: NotificationType { get }
    
    func identifier() -> String
    func title() -> String
    func body() -> String
    func date() -> Date
    func userInfo() -> [AnyHashable : Any]
}

extension LocalNotification {
    func userInfo() -> [AnyHashable : Any] {
        return [ kActivityResourceId : activity.resourceId ]
    }
}
