//
//  TimeMachineTests.swift
//  TimeSlower2
//
//  Created by Aleksander Shcherbakov on 7/13/15.
//  Copyright (c) 2015 1lastDay. All rights reserved.
//

import UIKit
import XCTest
@testable import TimeSlowerKit

class TimeMachineTests: XCTestCase {

    var shortDateFromatter: DateFormatter!
    var timeMachine: TimeMachine!
    var testStartDate: Date!
    var testFinishDate: Date!
    
    override func setUp() {
        super.setUp()
        shortDateFromatter = StaticDateFormatter.shortDateAndTimeFormatter
        timeMachine = TimeMachine()
        
        testStartDate = shortDateFromatter.date(from: "8/21/16, 10:15 AM")
        testFinishDate = shortDateFromatter.date(from: "8/21/16, 10:45 AM")
    }
    
    override func tearDown() {
        shortDateFromatter = nil
        testStartDate = nil
        testFinishDate = nil
        timeMachine = nil
        super.tearDown()
    }

    
    //MARK: - next offcurance of day tests
    
    func testNextDayWithNameFromDateNextSaturdayFromWednesday() {
        let wednesdayDate = shortDateFromatter.date(from: "7/8/15, 10:00 AM")!
        let correctNextSaturday = shortDateFromatter.date(from: "7/11/15, 10:00 AM")!
        
        let saturday = Weekday(rawValue: 6)!
        let nextSaturday = timeMachine.nextOccuranceOfWeekday(saturday, fromDate: wednesdayDate)
        XCTAssertEqual(nextSaturday, correctNextSaturday, "Next Saturday must be 11th")
    }
    
    func testNextDayWithNameFromDateNextSundayFromSaturday() {
        let saturdayDate = shortDateFromatter.date(from: "7/11/15, 10:00 AM")
        let correctNextSunday = shortDateFromatter.date(from: "7/12/15, 10:00 AM")
        
        let sunday = Weekday(rawValue: 0)!

        let nextSunday = timeMachine.nextOccuranceOfWeekday(sunday, fromDate: saturdayDate!)
        XCTAssertEqual(nextSunday, correctNextSunday!, "Next Sunday must be 12th")
    }
    
    func testNextDayWithNameFromDateNextSundayFromSunday() {
        let sundayDate = shortDateFromatter.date(from: "7/12/15, 10:00 AM")
        let correctNextSunday = shortDateFromatter.date(from: "7/19/15, 10:00 AM")
        
        let sunday = Weekday(rawValue: 0)!

        let nextSunday = timeMachine.nextOccuranceOfWeekday(sunday, fromDate: sundayDate!)
        XCTAssertEqual(nextSunday, correctNextSunday!, "Next Sunday must be 19th")
    }
    
    func testNextDayWithNameFromDateNextMondayFromFriday() {
        let fridayDate = shortDateFromatter.date(from: "7/10/15, 10:00 AM")
        let correctNextMonday = shortDateFromatter.date(from: "7/13/15, 10:00 AM")
        
        let monday = Weekday(rawValue: 1)!

        let nextMonday = timeMachine.nextOccuranceOfWeekday(monday, fromDate: fridayDate!)
        XCTAssertEqual(nextMonday, correctNextMonday!, "Next Monday must be 13th")
    }
    
    func testNextDayWithNameFromDateNextWeekendDayFromSunday() {
        let sundayDate = shortDateFromatter.date(from: "7/12/15, 10:00 AM")
        let correctNextWeekendDay = shortDateFromatter.date(from: "7/18/15, 10:00 AM")
        
        let saturday = Weekday(rawValue: 6)!

        let nextSaturday = timeMachine.nextOccuranceOfWeekday(saturday, fromDate: sundayDate!)
        XCTAssertEqual(nextSaturday, correctNextWeekendDay!, "Next Weekendday must be 18th")
    }
    
    func testNextDayWithNameFromDateNextThursdayFromMonday() {
        let mondayDate = shortDateFromatter.date(from: "7/6/15, 10:00 AM")
        let correctNextThursday = shortDateFromatter.date(from: "7/9/15, 10:00 AM")
        
        let thursday = Weekday(rawValue: 4)!

        let nextThursday = timeMachine.nextOccuranceOfWeekday(thursday, fromDate: mondayDate!)
        XCTAssertEqual(nextThursday, correctNextThursday!, "Next Thursday must be 18th")
    }
    
    // MARK: - End Date
    
    func test_startDateForPeriod() {
        let date = shortDateFromatter.date(from: "7/8/15, 10:00 AM")!
        let monthBeforDate = shortDateFromatter.date(from: "6/8/15, 10:00 AM")!
        let yearBeforeDate = shortDateFromatter.date(from: "7/8/14, 10:00 AM")!

        XCTAssertEqual(timeMachine.startDateForPeriod(.today, sinceDate: date), date)
        XCTAssertEqual(timeMachine.startDateForPeriod(.lastMonth, sinceDate: date), monthBeforDate)
        XCTAssertEqual(timeMachine.startDateForPeriod(.lastYear, sinceDate: date), yearBeforeDate)
    }

    func test_numberOfDatesInPeriod() {
        let date = shortDateFromatter.date(from: "7/8/15, 10:00 AM")!
        let monthBeforDate = shortDateFromatter.date(from: "6/8/15, 10:00 AM")!
        let yearBeforeDate = shortDateFromatter.date(from: "7/8/14, 10:00 AM")!
        
        XCTAssertEqual(timeMachine.numberOfDaysInPeriod(.today, fromDate: date), 0)
        XCTAssertEqual(timeMachine.numberOfDaysInPeriod(.lastMonth, fromDate: monthBeforDate), 31)
        XCTAssertEqual(timeMachine.numberOfDaysInPeriod(.lastYear, fromDate: yearBeforeDate), 365)
    }
    
    // MARK: - Date manipulations
    
    func test_updatedTimeForDate() {
        let time = shortDateFromatter.date(from: "8/23/16, 10:00 AM")!
        let newDate = shortDateFromatter.date(from: "3/28/17, 12:00 PM")!
        let expectedDate = shortDateFromatter.date(from: "3/28/17, 10:00 AM")!
        let result = timeMachine.updatedTime(time, forDate: newDate)
        XCTAssertEqual(result, expectedDate, "it should give updated date")
    }
    
    // MARK: - Fact Duration
    
    func test_factDurationFromStart() {
        XCTAssertEqual(timeMachine.minutesFromStart(testStartDate, toFinish: testFinishDate), 30)
    }
    
    func test_factDurationFromFinishToStart() {
        XCTAssertEqual(timeMachine.minutesFromStart(testFinishDate, toFinish: testStartDate), 30)
    }
    
    func test_factDurationFromFinishToFinish() {
        XCTAssertEqual(timeMachine.minutesFromStart(testFinishDate, toFinish: testFinishDate), 0)
    }

}
