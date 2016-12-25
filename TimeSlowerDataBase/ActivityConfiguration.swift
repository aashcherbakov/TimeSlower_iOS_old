//
//  ActivityConfiguration.swift
//  TimeSlowerKit
//
//  Created by Alexander Shcherbakov on 9/6/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation

public struct ActivityConfiguration: EntityConfiguration {
    
    public let name: String
    public let days: [Int]
    public let timing: TimingData
    public let stats: EstimationData
    public let notifications: Bool
    public let resourceId: String

    
    public init(name: String, days: [Int], timing: TimingData, stats: EstimationData, notifications: Bool, resourceId: String) {
        self.name = name
        self.days = days
        self.timing = timing
        self.stats = stats
        self.notifications = notifications
        self.resourceId = resourceId
    }
}
