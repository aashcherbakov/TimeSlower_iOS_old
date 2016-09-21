//
//  Timing.swift
//  TimeSlowerKit
//
//  Created by Oleksandr Shcherbakov on 9/4/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation

public struct Timing {
    public let duration: Endurance
    public let alarmTime: Date
    public let startTime: Date
    public let finishTime: Date
    public var manuallyStarted: Date?
    public let timeToSave: Double
}
