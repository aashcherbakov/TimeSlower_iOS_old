//
//  StatsTests.swift
//  TimeSlowerKit
//
//  Created by Oleksandr Shcherbakov on 9/4/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import XCTest
import TimeSlowerKit

class StatsTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func test_statsForDuration() {
        let stats = Stats(withDuration: 30, busyDays: 7, totalDays: 18105)
        XCTAssertEqual(stats.summHours, 9052.5)
        XCTAssertEqual(stats.summDays, 377.1875)
        XCTAssertEqualWithAccuracy(stats.summMonths, 12.5, accuracy: 0.1)
        XCTAssertEqualWithAccuracy(stats.summYears, 1, accuracy: 0.1)
    }
}
