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
    public let type: Int
    public let days: [Int]
    public let timing: TimingData
    public let stats: StatsData
    public let notifications: Bool
    public let averageSuccess: Double
    public let resourceId: String

    
    public init(name: String, type: Int, days: [Int], timing: TimingData, stats: StatsData, notifications: Bool, averageSuccess: Double, resourceId: String) {
        self.name = name
        self.type = type
        self.days = days
        self.timing = timing
        self.stats = stats
        self.notifications = notifications
        self.averageSuccess = averageSuccess
        self.resourceId = resourceId
    }
}
