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
    
    override func setUp() {
        super.setUp()
        shortDateFormatter = StaticDateFormatter.shortDateNoTimeFromatter
        shortTimeFormatter = StaticDateFormatter.shortDateAndTimeFormatter
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func test_createResult() {
        let testDateString = "8/21/16"
        let date = shortDateFormatter.dateFromString(testDateString)!
        
        let result = DayResults.newResultWithDate(date, forActivity: testActivity)
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result.activity, testActivity, "it should assign test activity as owner")
        XCTAssertEqual(shortDateFormatter.stringFromDate(result.raughDate), testDateString)
        XCTAssertEqual(shortTimeFormatter.stringFromDate(result.factFinishTime), "\(testDateString), 12:00 AM")
        XCTAssertEqual(result.date, testDateString)
        
        let expectedStartTime = shortDateFormatter.dateFromString("\(testDateString), 10:15 AM")
        XCTAssertEqual(result.factStartTime, expectedStartTime)
    }
    
    func test_fetchResultWithDate() {
        
    }
}
