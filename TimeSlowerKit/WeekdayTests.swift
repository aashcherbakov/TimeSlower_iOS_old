//
//  WeekdayTests.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 5/1/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import XCTest
@testable import TimeSlowerKit

class WeekdayTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func test_dateManagerReturnsDayName_fromWeekday() {
        XCTAssertEqual(Weekday.First.shortName, "Sun",
                       "it should be Monday")
        XCTAssertEqual(Weekday.Second.shortName, "Mon",
                       "it should be Tuesday")
    }
    
    // MARK: - isWorkday()
    
    func test_isWorkday() {
        XCTAssertTrue(Weekday.Second.isWorkday, "it should be workday in USA")
        XCTAssertTrue(Weekday.Sixth.isWorkday, "it should be workday in USA")
    }
    
    func test_isWeekend() {
        XCTAssertFalse(Weekday.First.isWorkday, "it should be weekend in USA")
        XCTAssertFalse(Weekday.Seventh.isWorkday, "it should be weekend in USA")
    }

    
    // MARK: - weekdaysForBasis()
    
    func test_weekdaysForDaily() {
        // given
        let expected: [Weekday] = [.First, .Second, .Third, .Forth, .Fifth, .Sixth, .Seventh]
        
        // when
        let result = Weekday.weekdaysForBasis(.Daily)
        
        // then
        XCTAssertEqual(expected, result,
                       "it should be all week")
        XCTAssertEqual(result.count, 7,
                       "it should be 7 days in array")
    }
    
    func test_weekdaysForWeekends() {
        // given
        let expected: [Weekday] = [.First, .Seventh]
        
        // when
        let result = Weekday.weekdaysForBasis(.Weekends)
        
        // then
        XCTAssertEqual(expected, result,
                       "it should be all week")
        XCTAssertEqual(result.count, 2,
                       "it should be 2 days in array")
    }
    
    func test_weekdaysForWorkdays() {
        // given
        let expected: [Weekday] = [.Second, .Third, .Forth, .Fifth, .Sixth]
        
        // when
        let result = Weekday.weekdaysForBasis(.Workdays)
        
        // then
        XCTAssertEqual(expected, result,
                       "it should be all week")
        XCTAssertEqual(result.count, 5,
                       "it should be 5 days in array")
    }
    
}
