//
//  ResultConfiguration.swift
//  TimeSlowerKit
//
//  Created by Alexander Shcherbakov on 9/10/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation

public struct ResultConfiguration: EntityConfiguration {
    
    public let stringDate: String
    public let duration: Double
    public let startTime: Date
    public let finishTime: Date
    public let savedTime: Double?
    public let success: Double
    public let date: Date
    public let resourceId: String

    public init(stringDate: String, duration: Double, startTime: Date, finishTime: Date, savedTime: Double?, success: Double, date: Date, resourceId: String) {
        self.stringDate = stringDate
        self.duration = duration
        self.startTime = startTime
        self.finishTime = finishTime
        self.savedTime = savedTime
        self.success = success
        self.date = date
        self.resourceId = resourceId
    }
}
