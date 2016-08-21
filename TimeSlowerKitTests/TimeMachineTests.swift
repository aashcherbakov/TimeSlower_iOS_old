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

    var shortDateFromatter: NSDateFormatter!
    var timeMachine: TimeMachine!
    
    override func setUp() {
        super.setUp()
        shortDateFromatter = StaticDateFormatter.shortDateAndTimeFormatter
        timeMachine = TimeMachine()
    }
    
    override func tearDown() {
        shortDateFromatter = nil
        super.tearDown()
    }

    
    //MARK: - next offcurance of day tests
    
    func testNextDayWithNameFromDateNextSaturdayFromWednesday() {
        let wednesdayDate = shortDateFromatter.dateFromString("7/8/15, 10:00 AM")!
        let correctNextSaturday = shortDateFromatter.dateFromString("7/11/15, 10:00 AM")!
        
        let saturday = Weekday(rawValue: 6)!
        let nextSaturday = timeMachine.nextOccuranceOfWeekday(saturday, fromDate: wednesdayDate)
        XCTAssertEqual(nextSaturday, correctNextSaturday, "Next Saturday must be 11th")
    }
    
    func testNextDayWithNameFromDateNextSundayFromSaturday() {
        let saturdayDate = shortDateFromatter.dateFromString("7/11/15, 10:00 AM")
        let correctNextSunday = shortDateFromatter.dateFromString("7/12/15, 10:00 AM")
        
        let sunday = Weekday(rawValue: 0)!

        let nextSunday = timeMachine.nextOccuranceOfWeekday(sunday, fromDate: saturdayDate!)
        XCTAssertEqual(nextSunday, correctNextSunday!, "Next Sunday must be 12th")
    }
    
    func testNextDayWithNameFromDateNextSundayFromSunday() {
        let sundayDate = shortDateFromatter.dateFromString("7/12/15, 10:00 AM")
        let correctNextSunday = shortDateFromatter.dateFromString("7/19/15, 10:00 AM")
        
        let sunday = Weekday(rawValue: 0)!

        let nextSunday = timeMachine.nextOccuranceOfWeekday(sunday, fromDate: sundayDate!)
        XCTAssertEqual(nextSunday, correctNextSunday!, "Next Sunday must be 19th")
    }
    
    func testNextDayWithNameFromDateNextMondayFromFriday() {
        let fridayDate = shortDateFromatter.dateFromString("7/10/15, 10:00 AM")
        let correctNextMonday = shortDateFromatter.dateFromString("7/13/15, 10:00 AM")
        
        let monday = Weekday(rawValue: 1)!

        let nextMonday = timeMachine.nextOccuranceOfWeekday(monday, fromDate: fridayDate!)
        XCTAssertEqual(nextMonday, correctNextMonday!, "Next Monday must be 13th")
    }
    
    func testNextDayWithNameFromDateNextWeekendDayFromSunday() {
        let sundayDate = shortDateFromatter.dateFromString("7/12/15, 10:00 AM")
        let correctNextWeekendDay = shortDateFromatter.dateFromString("7/18/15, 10:00 AM")
        
        let saturday = Weekday(rawValue: 6)!

        let nextSaturday = timeMachine.nextOccuranceOfWeekday(saturday, fromDate: sundayDate!)
        XCTAssertEqual(nextSaturday, correctNextWeekendDay!, "Next Weekendday must be 18th")
    }
    
    func testNextDayWithNameFromDateNextThursdayFromMonday() {
        let mondayDate = shortDateFromatter.dateFromString("7/6/15, 10:00 AM")
        let correctNextThursday = shortDateFromatter.dateFromString("7/9/15, 10:00 AM")
        
        let thursday = Weekday(rawValue: 4)!

        let nextThursday = timeMachine.nextOccuranceOfWeekday(thursday, fromDate: mondayDate!)
        XCTAssertEqual(nextThursday, correctNextThursday!, "Next Thursday must be 18th")
    }
    
    // MARK: - End Date
    
    func test_startDateForPeriod() {
        let date = shortDateFromatter.dateFromString("7/8/15, 10:00 AM")!
        let monthBeforDate = shortDateFromatter.dateFromString("6/8/15, 10:00 AM")!
        let yearBeforeDate = shortDateFromatter.dateFromString("7/8/14, 10:00 AM")!

        XCTAssertEqual(timeMachine.startDateForPeriod(.Today, sinceDate: date), date)
        XCTAssertEqual(timeMachine.startDateForPeriod(.LastMonth, sinceDate: date), monthBeforDate)
        XCTAssertEqual(timeMachine.startDateForPeriod(.LastYear, sinceDate: date), yearBeforeDate)
    }

    func test_numberOfDatesInPeriod() {
        let date = shortDateFromatter.dateFromString("7/8/15, 10:00 AM")!
        let monthBeforDate = shortDateFromatter.dateFromString("6/8/15, 10:00 AM")!
        let yearBeforeDate = shortDateFromatter.dateFromString("7/8/14, 10:00 AM")!
        
        XCTAssertEqual(timeMachine.numberOfDaysInPeriod(.Today, fromDate: date), 0)
        XCTAssertEqual(timeMachine.numberOfDaysInPeriod(.LastMonth, fromDate: monthBeforDate), 31)
        XCTAssertEqual(timeMachine.numberOfDaysInPeriod(.LastYear, fromDate: yearBeforeDate), 365)
    }
}
