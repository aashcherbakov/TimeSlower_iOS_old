//
//  LazyCalendarTests.swift
//  TimeSlower2
//
//  Created by Aleksander Shcherbakov on 7/13/15.
//  Copyright (c) 2015 1lastDay. All rights reserved.
//

import UIKit
import XCTest

class LazyCalendarTests: XCTestCase {

    var shortDateFromatter: NSDateFormatter!
    
    override func setUp() {
        super.setUp()
        shortDateFromatter = TestCoreDataStack().shortStyleDateFormatter()
    }
    
    override func tearDown() {
        shortDateFromatter = nil
        super.tearDown()
    }
    
    func testCorrectWeekdayFromDate() {
        let testDate = DayResults.standardDateFormatter().dateFromString("7/6/15")
        let shortName = LazyCalendar.correctWeekdayFromDate(testDate!)
        XCTAssertEqual(shortName, "Mon", "Correct weekday must be monday")
    }
    
    
    //MARK: - nextDayWithName tests
    
    func testNextDayWithNameFromDateNextSaturdayFromWednesday() {
        let wednesdayDate = shortDateFromatter.dateFromString("7/8/15, 10:00 AM")
        let correctNextSaturday = shortDateFromatter.dateFromString("7/11/15, 10:00 AM")
        let nextSaturday = LazyCalendar.nextDayWithName(.Saturday, fromDate: wednesdayDate!)
        XCTAssertEqual(nextSaturday, correctNextSaturday!, "Next Saturday must be 11th")
    }
    
    func testNextDayWithNameFromDateNextSundayFromSaturday() {
        let saturdayDate = shortDateFromatter.dateFromString("7/11/15, 10:00 AM")
        let correctNextSunday = shortDateFromatter.dateFromString("7/12/15, 10:00 AM")
        let nextSunday = LazyCalendar.nextDayWithName(.Sunday, fromDate: saturdayDate!)
        XCTAssertEqual(nextSunday, correctNextSunday!, "Next Sunday must be 12th")
    }
    
    func testNextDayWithNameFromDateNextSundayFromSunday() {
        let sundayDate = shortDateFromatter.dateFromString("7/12/15, 10:00 AM")
        let correctNextSunday = shortDateFromatter.dateFromString("7/19/15, 10:00 AM")
        let nextSunday = LazyCalendar.nextDayWithName(.Sunday, fromDate: sundayDate!)
        XCTAssertEqual(nextSunday, correctNextSunday!, "Next Sunday must be 19th")
    }
    
    func testNextDayWithNameFromDateNextMondayFromFriday() {
        let fridayDate = shortDateFromatter.dateFromString("7/10/15, 10:00 AM")
        let correctNextMonday = shortDateFromatter.dateFromString("7/13/15, 10:00 AM")
        let nextMonday = LazyCalendar.nextDayWithName(.Monday, fromDate: fridayDate!)
        XCTAssertEqual(nextMonday, correctNextMonday!, "Next Monday must be 13th")
    }
    
    func testNextDayWithNameFromDateNextWeekendDayFromSunday() {
        let sundayDate = shortDateFromatter.dateFromString("7/12/15, 10:00 AM")
        let correctNextWeekendDay = shortDateFromatter.dateFromString("7/18/15, 10:00 AM")
        let nextSaturday = LazyCalendar.nextDayWithName(.Saturday, fromDate: sundayDate!)
        XCTAssertEqual(nextSaturday, correctNextWeekendDay!, "Next Weekendday must be 18th")
    }
    
    func testNextDayWithNameFromDateNextThursdayFromMonday() {
        let mondayDate = shortDateFromatter.dateFromString("7/6/15, 10:00 AM")
        let correctNextThursday = shortDateFromatter.dateFromString("7/9/15, 10:00 AM")
        let nextThursday = LazyCalendar.nextDayWithName(.Thursday, fromDate: mondayDate!)
        XCTAssertEqual(nextThursday, correctNextThursday!, "Next Thursday must be 18th")
    }


}
