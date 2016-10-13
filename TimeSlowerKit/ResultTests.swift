//
//  ResultTests.swift
//  TimeSlowerKit
//
//  Created by Oleksandr Shcherbakov on 9/4/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import XCTest
@testable import TimeSlowerKit

class ResultTests: XCTestCase {

    var shortTimeFormatter: DateFormatter!
    var testStartDate: Date!
    var testFinishDate: Date!
    var testDateString: String!
    var testTiming: Timing!
    
    override func setUp() {
        super.setUp()
        
        shortTimeFormatter = StaticDateFormatter.shortDateAndTimeFormatter
        testDateString = "8/21/16"
        testStartDate = shortTimeFormatter.date(from: "8/21/16, 10:15 AM")
        testFinishDate = shortTimeFormatter.date(from: "8/21/16, 10:45 AM")
       
        testTiming = Timing(
            withDuration: Endurance(value: 40, period: .minutes),
            startTime: testStartDate,
            timeToSave: 10,
            alarmTime: Date(),
            manuallyStarted: testFinishDate)
    }
    
    override func tearDown() {
        shortTimeFormatter = nil
        testDateString = nil
        testStartDate = nil
        testFinishDate = nil
        super.tearDown()
    }
    
    // MARK: - Creation
    
    func test_init() {
        let testActivity = Activity(withLifetimeDays: 18105, name: "Blah", type: .routine, days: [], timing: testTiming, notifications: false)
        
        let result = Result(withActivity: testActivity, factFinish: testFinishDate)
        
        XCTAssertEqual(result.startTime, testStartDate)
        XCTAssertEqual(result.finishTime, testFinishDate)
        XCTAssertEqual(result.duration, 30)
        XCTAssertEqual(result.success, 100)
        XCTAssertEqual(result.savedTime, 10)
        XCTAssertEqual(result.stringDate, "8/21/16")
        XCTAssertEqual(result.activity.name, "Blah")
    }

    // MARK: - Main success method
    
    func test_daySuccessForTiming() {
        let success = Result.daySuccessForTiming(testTiming, activityType: .routine, startTime: testStartDate, finishTime: testFinishDate)
        XCTAssertEqual(success, 100, "it should have 100% success")
    }
    
}
