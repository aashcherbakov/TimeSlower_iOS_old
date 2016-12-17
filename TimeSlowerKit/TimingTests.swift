//
//  TimingTests.swift
//  TimeSlowerKit
//
//  Created by Oleksandr Shcherbakov on 9/4/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import XCTest
@testable import TimeSlowerKit

class TimingTests: XCTestCase {
    var sut: Timing!

    override func setUp() {
        super.setUp()

        sut = Timing(
            withDuration: Endurance(value: 1, period: .hours),
            startTime: Date(),
            timeToSave: 20,
            alarmTime: Date())
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

}

