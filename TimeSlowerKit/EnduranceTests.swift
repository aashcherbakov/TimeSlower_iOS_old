//
//  EnduranceTests.swift
//  TimeSlowerKit
//
//  Created by Oleksandr Shcherbakov on 9/4/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import XCTest
import TimeSlowerKit

class EnduranceTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func test_seconds() {
        let duration = Endurance(value: 1, period: .minutes)
        XCTAssertEqual(duration.seconds(), 60)
        
        let hours = Endurance(value: 1, period: .hours)
        XCTAssertEqual(hours.seconds(), 3600)
    }
    
    func test_minutes() {
        let duration = Endurance(value: 1, period: .minutes)
        XCTAssertEqual(duration.minutes(), 1)
        
        let hours = Endurance(value: 1, period: .hours)
        XCTAssertEqual(hours.minutes(), 60)
    }
    
    func test_hours() {
        let hours = Endurance(value: 1, period: .hours)
        XCTAssertEqual(hours.hours(), 1)
        
        let minutes = Endurance(value: 1, period: .minutes)
        XCTAssertTrue(Double(minutes.hours()) < 0.02)
    }
}
