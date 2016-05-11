//
//  DayTests.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 4/28/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import XCTest
@testable import TimeSlowerKit

class DateManagerTests: XCTestCase {
    
    var tuesday: NSDate!
    
    override func setUp() {
        super.setUp()
        tuesday = TestHelper.tuesdayApril26()
        
    }
    
    override func tearDown() {
        tuesday = nil
        super.tearDown()
    }
    
    func test_dateManagerReturnsDayName_forDayNumber() {
        XCTAssertEqual(DateManager.shortDayNameForDate(tuesday),
                       "Tue", "it should be equal to Tue")
    }
    
    // MARK: - basisFromWeekdays()
    
    func test_basisFromWeekends() {
        // given
        let days: [Weekday] = [.First, .Seventh]
        
        // when
        let basis = DateManager.basisFromWeekdays(days)
        
        // then
        XCTAssertEqual(basis, Basis.Weekends,
                           "it should be weekends basis")
    }
    
    func test_basisFromWorkdays() {
        // given
        let days: [Weekday] = [.Second, .Third, .Forth, .Fifth, .Sixth]
        
        // when
        let basis = DateManager.basisFromWeekdays(days)
        
        // then
        XCTAssertEqual(basis, Basis.Workdays,
                       "it should be weekends basis")
    }
    
    func test_basisFromDaily() {
        // given
        let days: [Weekday] = [.First, .Second, .Third, .Forth, .Fifth, .Sixth, .Seventh]
        
        // when
        let basis = DateManager.basisFromWeekdays(days)
        
        // then
        XCTAssertEqual(basis, Basis.Daily,
                       "it should be weekends basis")
    }
    
    func test_basisFromRandom() {
        // given
        let days: [Weekday] = [.First, .Sixth, .Seventh]
        
        // when
        let basis = DateManager.basisFromWeekdays(days)
        
        // then
        XCTAssertEqual(basis, Basis.Random,
                       "it should be weekends basis")
    }
}
