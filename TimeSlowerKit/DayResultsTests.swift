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
        let date = shortDateFormatter.dateFromString("8/21/16")!
        
        let result = DayResults.newResultWithDate(date, forActivity: testActivity)
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result.activity, testActivity, "it should assign test activity as owner")
        XCTAssertEqual(shortDateFormatter.stringFromDate(result.raughDate), "8/21/16")
        XCTAssertEqual(shortTimeFormatter.stringFromDate(result.factFinishTime), "8/21/16, 12:00 AM")
        XCTAssertEqual(result.date, "8/21/16")
        
    }
    
    func test_fetchResultWithDate() {
        
    }
}
