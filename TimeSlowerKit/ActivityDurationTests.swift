//
//  ActivityDurationTests.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 7/10/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import XCTest
import TimeSlowerKit

class ActivityDurationTests: XCTestCase {
    
    func test_seconds() {
        let duration = ActivityDuration(value: 1, period: .minutes)
        XCTAssertEqual(duration.seconds(), 60)
        
        let hours = ActivityDuration(value: 1, period: .hours)
        XCTAssertEqual(hours.seconds(), 3600)
    }

    func test_minutes() {
        let duration = ActivityDuration(value: 1, period: .minutes)
        XCTAssertEqual(duration.minutes(), 1)
        
        let hours = ActivityDuration(value: 1, period: .hours)
        XCTAssertEqual(hours.minutes(), 60)
    }
    
    func test_hours() {
        let hours = ActivityDuration(value: 1, period: .hours)
        XCTAssertEqual(hours.hours(), 1)
        
        let minutes = ActivityDuration(value: 1, period: .minutes)
        XCTAssertTrue(Double(minutes.hours()) < 0.02)
    }
}
 
