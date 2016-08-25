//
//  DayResultsTests.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 8/21/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import XCTest
import TimeSlowerKit

class DayResultsTests: CoreDataBaseTest {

    var shortDateFormatter: NSDateFormatter!
    var shortTimeFormatter: NSDateFormatter!
    var testDateString: String!
    var testFinishDate: NSDate!
    var sut: DayResults!
    
    override func setUp() {
        super.setUp()
        shortDateFormatter = StaticDateFormatter.shortDateNoTimeFromatter
        shortTimeFormatter = StaticDateFormatter.shortDateAndTimeFormatter
        testDateString = "8/21/16"
        
        testFinishDate = shortTimeFormatter.dateFromString("\(testDateString), 10:45 AM")
        
        sut = DayResults.newResultWithDate(testFinishDate, forActivity: testActivity)
    }
    
    override func tearDown() {
        sut = nil
        testDateString = nil
        super.tearDown()
    }

    func test_createResult() {
        let result = DayResults.newResultWithDate(testFinishDate, forActivity: testActivity)
        let expectedStartTime = shortTimeFormatter.dateFromString("\(testDateString), 10:15 AM")!

        XCTAssertNotNil(result)
        XCTAssertEqual(result.activity, testActivity, "it should assign test activity as owner")
        XCTAssertEqual(shortDateFormatter.stringFromDate(result.raughDate), testDateString)
        XCTAssertEqual(shortTimeFormatter.stringFromDate(result.factFinishTime), "\(testDateString), 10:45 AM")
        XCTAssertEqual(result.date, testDateString, "it should be 8/21/16")
        XCTAssertEqual(result.factStartTime, expectedStartTime, "it should be 10:15 AM")
        XCTAssertEqual(result.factDuration, 30, "it should be 95 minutes")
    }
    
    func test_factDurationFromStartToFinish() {
        let start = result.factStartTime
        let finish = result.factFinishTime
        XCTAssertEqual(shortTimeFormatter.stringFromDate(start), "8/21/16, 10:15 AM")
        XCTAssertEqual(shortTimeFormatter.stringFromDate(finish), "8/21/16, 10:45 AM")
        XCTAssertEqual(sut.factDuration, 30, "It should be 30 minutes")
    }
    
//    func test_daySuccessForRoutine() {
//        XCTAssertEqual(<#T##expression1: [T : U]##[T : U]#>, <#T##expression2: [T : U]##[T : U]#>)
//    }
    
    func test_fetchResultWithDate() {
    }
}
