//
//  StatsManageTest.swift
//  TimeSlower2
//
//  Created by Aleksander Shcherbakov on 7/3/15.
//  Copyright (c) 2015 1lastDay. All rights reserved.
//

import UIKit
import XCTest
import CoreData
import TimeSlowerKit

class StatsManageTest: CoreDataBaseTest {

    var testResult: DayResults!
    var testActivityForDeletion: Activity!
    
    var testDateFormatter: DateFormatter!
    var standartDateFormatter: DateFormatter!
    var timeMachine: TimeMachine!
    
    //MARK: - Setup
    
    override func setUp() {
        super.setUp()
        
        testResult = testCoreDataStack.fakeResultForActivity(testActivity)
        testDateFormatter = testCoreDataStack.shortStyleDateFormatter()
        standartDateFormatter = DayResults.standardDateFormatter()
        timeMachine = TimeMachine()
    }
    
    override func tearDown() {
        testCoreDataStack = nil
        testContext = nil
        testProfile = nil
        testActivity = nil
        testDateFormatter = nil
        standartDateFormatter = nil
        super.tearDown()
    }
    
    func test_newStatsForActivity() {
        let stats = Stats.newStatsForActivity(activity: testActivity)
        XCTAssertNotNil(stats, "it should create stats object")
        XCTAssertEqual(stats.activity, testActivity, "it should assign fake activity")
        XCTAssertEqual(testActivity.stats, stats, "it should replace stats in test activity")
    }
    
    func test_updateStats() {
        testActivity.stats.updateStatsForDate(
            DayResults.standardDateFormatter().date(from: "08/28/16")!)
        XCTAssertEqual(testActivity.stats.summHours.doubleValue, 8689.5, "Summ hours 8689")
        XCTAssertEqual(testActivity.stats.summDays.doubleValue, 362.0625, "Summ days must be 362")
        XCTAssertEqual(testActivity.stats.summMonths.doubleValue, 12.06875, "Summ months must be 12")
        XCTAssertEqualWithAccuracy(testActivity.stats.summYears.doubleValue, 1, accuracy: 0.1, "Summ years must be 1")
    }
    
    func test_updateAvarageSuccess() {
        testResult.factSuccess = 70
        testActivity.stats.updateSuccessWithResult(testResult)
        let result1 = DayResults.newResultWithDate(TestHelper.mondayApril25(), forActivity: testActivity)
        result1.factSuccess = 50
        testActivity.stats.updateSuccessWithResult(result1)
        let result2 = DayResults.newResultWithDate(TestHelper.saturdayApril30(), forActivity: testActivity)
        result2.factSuccess = 60
        testActivity.stats.updateSuccessWithResult(result2)
        
        XCTAssertEqual(testActivity.stats.averageSuccess, 60)
    }
    
    //MARK: - Savings: saved/planned
    //MARK: - - Lifetime
    
    func testFactSpentInLifetime() {
        testActivity.stats.averageSuccess = NSNumber(value: 70 as Double)
        let timeSpentInFuture = testActivity.stats.factTimingInLifetime()
        XCTAssertGreaterThan(timeSpentInFuture!.hours, 1900, "Total days spendings should be more than 1900")
        XCTAssertGreaterThan(timeSpentInFuture!.days, 70, "Total days spendings should be more than 70")
        XCTAssertGreaterThan(timeSpentInFuture!.months, 1, "Total days spendings should be more than 1")
        XCTAssertGreaterThan(timeSpentInFuture!.years, 0, "Total days spendings should be more than 0")
    }
    
    func testTimePlannedTimingInLifeTime() {
        let plannedTime = testActivity.stats.plannedTimingInLifetime()
        XCTAssertGreaterThan(plannedTime!.hours, 2500, "Planned to save more than 2500 min")
        XCTAssertGreaterThan(plannedTime!.days, 100, "Planned to save 100 days")
        XCTAssertGreaterThan(plannedTime!.months, 3, "Planned to save more than 3 months")
        XCTAssertGreaterThan(plannedTime!.years, 0, "Planned to save more than 0 years")
    }
    
    //MARK: - Testing helper methods
    
    func testLastYearDate() {
        let referenceDate = standartDateFormatter.date(from: "7/9/15")
        let checkDate = standartDateFormatter.date(from: "7/9/14")
        let result = timeMachine.startDateForPeriod(.lastYear, sinceDate: referenceDate!)
        XCTAssertEqual(result, checkDate!, "Last year has to be 2014")
    }
    
    func testLastMonthDate() {
        var referenceDate = standartDateFormatter.date(from: "7/9/15")
        var checkDate = standartDateFormatter.date(from: "6/9/15")
        var result = timeMachine.startDateForPeriod(.lastMonth, sinceDate: referenceDate!)
        XCTAssertEqual(result, checkDate!, "Last month has to be June")
        
        referenceDate = standartDateFormatter.date(from: "1/1/15")
        checkDate = standartDateFormatter.date(from: "12/1/14")
        result = timeMachine.startDateForPeriod(.lastMonth, sinceDate: referenceDate!)
        XCTAssertEqual(result, checkDate!, "Last month has to be December")
    }
    
    func testNumberOfDaysInPeriod() {
        let referenceDate = standartDateFormatter.date(from: "7/9/15")
        let result = timeMachine.numberOfDaysInPeriod(.lastMonth, fromDate: referenceDate!)
        XCTAssertEqual(result, 30, "It had to be 30 days in that period")
    }
    
//    func testNumberOfWeekdaysNamedFriday() {
//        let referenceDate = standartDateFormatter.dateFromString("7/9/15")
//        let numberOfFridays = timeMachine.numberOfWeekdaysNamed(.Friday, forPeriod: .LastMonth, sinceDate: referenceDate!)
//        XCTAssertEqual(numberOfFridays, 4, "4 fridays a month")
//    }
//    
//    func testNumberOfWeekdaysNamedThursday() {
//        let referenceDate = standartDateFormatter.dateFromString("7/9/15")
//        let numberOfFridays = timeMachine.numberOfWeekdaysNamed(.Thursday, forPeriod: .LastMonth, sinceDate: referenceDate!)
//        XCTAssertEqual(numberOfFridays, 5, "5 thursdays a month")
//    }
    
//    func testBusyDaysForPeriod() {
//        let referenceDate = standartDateFormatter.dateFromString("7/9/15")!
//        testActivity.basis = Activity.basisWithEnum(.Weekends)
//        let daysInPeriod = testActivity.stats.busyDaysForPeriod(.LastMonth, sinceDate: referenceDate)
//        XCTAssertEqual(daysInPeriod, 8, "4 Saturdays and 4 Sundays")
//    }
    
//    func testBusyDaysForActivity() {
//
//        let referenceDate = standartDateFormatter.dateFromString("7/9/15")!
//
//        // daily basis
//        var numberOfBusyDays = testActivity.stats.busyDaysForPeriod(.LastMonth, sinceDate: referenceDate)
//        XCTAssertEqual(numberOfBusyDays, 30, "Number of busy days for daily activity last month is 30")
//        numberOfBusyDays = testActivity.stats.busyDaysForPeriod(.LastYear, sinceDate: referenceDate)
//        XCTAssertEqual(numberOfBusyDays, 365, "Number of busy days for daily activity last year is 365")
//
//        // weekend basis
//        testActivity.basis = Activity.basisWithEnum(.Weekends)
//        numberOfBusyDays = testActivity.stats.busyDaysForPeriod(.LastMonth, sinceDate: referenceDate)
//        XCTAssertEqual(numberOfBusyDays, 8, "Number of busy days for weekend activity last month is 30")
//        numberOfBusyDays = testActivity.stats.busyDaysForPeriod(.LastYear, sinceDate: referenceDate)
//        XCTAssertEqual(numberOfBusyDays, 106, "Number of busy days for weekend activity last year is 365")
//
//        // workday basis
//        testActivity.basis = Activity.basisWithEnum(.Workdays)
//        numberOfBusyDays = testActivity.stats.busyDaysForPeriod(.LastMonth, sinceDate: referenceDate)
//        XCTAssertEqual(numberOfBusyDays, 22, "Number of busy days for Workdays activity last month is 30")
//        numberOfBusyDays = testActivity.stats.busyDaysForPeriod(.LastYear, sinceDate: referenceDate)
//        XCTAssertEqual(numberOfBusyDays, 266, "Number of busy days for Workdays activity last year is 365")
//    }

}
