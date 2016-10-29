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
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: - Create from date
    
    func test_createFromDate() {
        let tuesday = TestHelper.tuesdayApril26()
        let weekday = Weekday.createFromDate(tuesday)
        XCTAssertEqual(weekday.rawValue, 2, "it should return third weekdayday")
        XCTAssertEqual(weekday.shortName, "Tue", "it should be Tuesday")
    }

    // MARK: - Short name
    
    func test_dateManagerReturnsDayName_fromWeekday() {
        XCTAssertEqual(Weekday.first.shortName, "Sun", "it should be Monday")
        XCTAssertEqual(Weekday.second.shortName, "Mon", "it should be Tuesday")
    }
    
    func test_correctWeekdayFromDate() {
        let date = TestHelper.mondayApril25()
        XCTAssertEqual(Weekday.shortDayNameForDate(date), "Mon", "it should be monday")
    }
    
    // MARK: - is workday
    
    func test_isWorkday() {
        XCTAssertTrue(Weekday.second.isWorkday, "it should be workday in USA")
        XCTAssertTrue(Weekday.sixth.isWorkday, "it should be workday in USA")
    }
    
    func test_isWeekend() {
        XCTAssertFalse(Weekday.first.isWorkday, "it should be weekend in USA")
        XCTAssertFalse(Weekday.seventh.isWorkday, "it should be weekend in USA")
    }
    
    // MARK: - closest day
    
    func test_closestDayToSunday() {
        let sunday = Weekday(rawValue: 0)!
        let saturday = Weekday(rawValue: 6)!
        let friday = Weekday(rawValue: 5)!
        let days = [saturday, friday]
        let closestDay = Weekday.closestDay(days, toDay: sunday)
        XCTAssertEqual(closestDay, friday)
    }
    
    func test_closestDayToSaturday() {
        let saturday = Weekday(rawValue: 6)!
        let sunday = Weekday(rawValue: 0)!
        let friday = Weekday(rawValue: 5)!
        let days = [sunday, friday]
        let closestDay = Weekday.closestDay(days, toDay: saturday)
        XCTAssertEqual(closestDay, sunday)
    }
    
    func test_closestDayToThursday() {
        let thursday = Weekday(rawValue: 4)!
        let monday = Weekday(rawValue: 1)!
        let tuesday = Weekday(rawValue: 2)!
        let days = [monday, tuesday]
        let closestDay = Weekday.closestDay(days, toDay: thursday)
        XCTAssertEqual(closestDay, monday)
    }
    
    // MARK: - weekdaysForBasis() - TimeSlower Specific Exptension
    
    func test_weekdaysForDaily() {
        // given
        let expected: [Weekday] = [.first, .second, .third, .forth, .fifth, .sixth, .seventh]
        
        // when
        let result = Weekday.weekdaysForBasis(.daily)
        
        // then
        XCTAssertEqual(expected, result,
                       "it should be all week")
        XCTAssertEqual(result.count, 7,
                       "it should be 7 days in array")
    }
    
    func test_weekdaysForWeekends() {
        // given
        let expected: [Weekday] = [.first, .seventh]
        
        // when
        let result = Weekday.weekdaysForBasis(.weekends)
        
        // then
        XCTAssertEqual(expected, result,
                       "it should be all week")
        XCTAssertEqual(result.count, 2,
                       "it should be 2 days in array")
    }
    
    func test_weekdaysForWorkdays() {
        // given
        let expected: [Weekday] = [.second, .third, .forth, .fifth, .sixth]
        
        // when
        let result = Weekday.weekdaysForBasis(.workdays)
        
        // then
        XCTAssertEqual(expected, result,
                       "it should be all week")
        XCTAssertEqual(result.count, 5,
                       "it should be 5 days in array")
    }
    
    func test_nextDate_nextSunday_nowFriday() {
        let day = Weekday.first // sunday
        let date = StaticDateFormatter.shortDateNoTimeFromatter.date(from: "10/28/2016")! // friday
        let nextDate = StaticDateFormatter.shortDateNoTimeFromatter.date(from: "10/30/2016")!
        XCTAssertEqual(day.nextDate(fromDay: date), nextDate)
    }
    
    func test_nextDate_nextTuesday_nowFriday() {
        let day = Weekday.third // tuesday
        let date = StaticDateFormatter.shortDateNoTimeFromatter.date(from: "10/28/2016")! // friday
        let nextDate = StaticDateFormatter.shortDateNoTimeFromatter.date(from: "11/1/2016")!
        XCTAssertEqual(day.nextDate(fromDay: date), nextDate)
    }

    func test_nextDate_nextWednesday_nowFriday() {
        let day = Weekday.forth // wednesday
        let date = StaticDateFormatter.shortDateNoTimeFromatter.date(from: "10/28/2016")! // friday
        let nextDate = StaticDateFormatter.shortDateNoTimeFromatter.date(from: "11/2/2016")!
        XCTAssertEqual(day.nextDate(fromDay: date), nextDate)
    }
    
    func test_nextDate_nextSunday_nowSaturday() {
        let day = Weekday.first // sunday
        let date = StaticDateFormatter.shortDateNoTimeFromatter.date(from: "10/29/2016")! // friday
        let nextDate = StaticDateFormatter.shortDateNoTimeFromatter.date(from: "10/30/2016")!
        XCTAssertEqual(day.nextDate(fromDay: date), nextDate)
    }
    
    func test_nextDate_nextSunday_nowSunday() {
        let day = Weekday.first // sunday
        let date = StaticDateFormatter.shortDateNoTimeFromatter.date(from: "10/30/2016")! // friday
        let nextDate = StaticDateFormatter.shortDateNoTimeFromatter.date(from: "11/6/2016")!
        XCTAssertEqual(day.nextDate(fromDay: date), nextDate)
    }
    
    func test_nextDate_nextMonday_nowSunday() {
        let day = Weekday.second // monday
        let date = StaticDateFormatter.shortDateNoTimeFromatter.date(from: "10/30/2016")! // sunday
        let nextDate = StaticDateFormatter.shortDateNoTimeFromatter.date(from: "10/31/2016")!
        XCTAssertEqual(day.nextDate(fromDay: date), nextDate)
    }

}
