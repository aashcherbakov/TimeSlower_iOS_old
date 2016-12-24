
//
//  EstimatorTests.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 7/17/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import XCTest
import TimeSlowerKit

class TimeCalculatorTests: XCTestCase {
    
    var sut: Estimator!

    override func setUp() {
        super.setUp()
        sut = Estimator()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func test_durationPerDay() {
        let minutes = sut.durationPerDay(20, busyDays: 5)
        XCTAssertEqualWithAccuracy(minutes, 14.2, accuracy: 0.1)
    }

    func test_hours() {
        let hours = sut.totalHours(inDays: 3, duration: 20, busyDays: 7)
        XCTAssertEqual(hours, 1)
    }
    
    func test_days() {
        let days = sut.totalDays(inDays: 365, duration: 20, busyDays: 7)
        XCTAssertEqualWithAccuracy(days, 5, accuracy: 0.1, "it should be around 5 days")
    }
    
    func test_months() {
        let months = sut.totalMonths(inDays: 14600, duration: 20, busyDays: 7)
        XCTAssertEqualWithAccuracy(months, 6.7, accuracy: 0.1, "it should be around 7 months")
    }

}
