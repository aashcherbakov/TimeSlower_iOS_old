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

class StatsManageTest: XCTestCase {

    var testCoreDataStack: TestCoreDataStack!
    var testContext: NSManagedObjectContext!
    
    var testProfile: Profile!
    var testActivity: Activity!
    var testResult: DayResults!
    var testActivityForDeletion: Activity!
    var testActivityStats: Stats!
    var testActivityTiming: Timing!
    
    var testDateFormatter: NSDateFormatter!
    var standartDateFormatter: NSDateFormatter!
    var timeMachine: TimeMachine!
    
    //MARK: - Setup
    
    override func setUp() {
        super.setUp()
        
        // CoreDataStack
        testCoreDataStack = TestCoreDataStack()
        testContext = testCoreDataStack.managedObjectContext
        
        // Creating fake instances
        testProfile = testCoreDataStack.fakeProfile()
        testActivity = testCoreDataStack.fakeActivityWithProfile(testProfile, type: .Routine, basis: .Daily)
        testResult = testCoreDataStack.fakeResultForActivity(testActivity)
        testActivityStats = testActivity.stats
        testActivityTiming = testActivity.timing
        testCoreDataStack.saveContext()
        
        testDateFormatter = testCoreDataStack.shortStyleDateFormatter()
        standartDateFormatter = DayResults.standardDateFormatter()
        timeMachine = TimeMachine()
    }
    
    override func tearDown() {
        testContext.deleteObject(testResult)
        testContext.deleteObject(testActivityTiming)
        testContext.deleteObject(testActivityStats)
        testContext.deleteObject(testActivity)
        testContext.deleteObject(testProfile)
        testCoreDataStack.saveContext()
        
        testCoreDataStack = nil
        testContext = nil
        testProfile = nil
        testActivity = nil
        testDateFormatter = nil
        standartDateFormatter = nil
        super.tearDown()
    }
    
    func testUpdateStats() {
        testActivity.stats.updateStats()
//        XCTAssertGreaterThan(testActivity.stats!.summHours.doubleValue, 2600, "Summ hours should be more than 2600")
//        XCTAssertGreaterThan(testActivity.stats!.summDays.doubleValue, 100, "Summ days should be more than 100")
//        XCTAssertGreaterThan(testActivity.stats!.summMonths.doubleValue, 3, "Summ months should be more than 3")
//        XCTAssertGreaterThan(testActivity.stats!.summYears.doubleValue, 0.2, "Summ years should be more than 0.2")
        XCTAssertLessThan(testActivity.stats.summHours.doubleValue, 3000, "Summ hours must be less then 3000")
        XCTAssertLessThan(testActivity.stats.summDays.doubleValue, 130, "Summ hours must be less then 3000")
        XCTAssertLessThan(testActivity.stats.summMonths.doubleValue, 5, "Summ hours must be less then 3000")
        XCTAssertLessThan(testActivity.stats.summYears.doubleValue, 0.5, "Summ hours must be less then 3000")
    }

    
    func testBusyDaysForActivity() {
        
        let referenceDate = standartDateFormatter.dateFromString("7/9/15")!
        
        // daily basis
        var numberOfBusyDays = testActivity.stats.busyDaysForPeriod(.LastMonth, sinceDate: referenceDate)
        XCTAssertEqual(numberOfBusyDays, 30, "Number of busy days for daily activity last month is 30")
        numberOfBusyDays = testActivity.stats.busyDaysForPeriod(.LastYear, sinceDate: referenceDate)
        XCTAssertEqual(numberOfBusyDays, 365, "Number of busy days for daily activity last year is 365")

        // weekend basis
        testActivity.basis = Activity.basisWithEnum(.Weekends)
        numberOfBusyDays = testActivity.stats.busyDaysForPeriod(.LastMonth, sinceDate: referenceDate)
        XCTAssertEqual(numberOfBusyDays, 8, "Number of busy days for weekend activity last month is 30")
        numberOfBusyDays = testActivity.stats.busyDaysForPeriod(.LastYear, sinceDate: referenceDate)
        XCTAssertEqual(numberOfBusyDays, 106, "Number of busy days for weekend activity last year is 365")
        
        // workday basis
        testActivity.basis = Activity.basisWithEnum(.Workdays)
        numberOfBusyDays = testActivity.stats.busyDaysForPeriod(.LastMonth, sinceDate: referenceDate)
        XCTAssertEqual(numberOfBusyDays, 22, "Number of busy days for Workdays activity last month is 30")
        numberOfBusyDays = testActivity.stats.busyDaysForPeriod(.LastYear, sinceDate: referenceDate)
        XCTAssertEqual(numberOfBusyDays, 266, "Number of busy days for Workdays activity last year is 365")
    }
    
    
    //MARK: - Savings: saved/planned
    //MARK: - - Lifetime
    
    func testFactSpentInLifetime() {
        testActivity.stats.averageSuccess = NSNumber(double: 70)
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
        let referenceDate = standartDateFormatter.dateFromString("7/9/15")
        let checkDate = standartDateFormatter.dateFromString("7/9/14")
        let result = timeMachine.startDateForPeriod(.LastYear, sinceDate: referenceDate!)
        XCTAssertEqual(result, checkDate!, "Last year has to be 2014")
    }
    
    func testLastMonthDate() {
        var referenceDate = standartDateFormatter.dateFromString("7/9/15")
        var checkDate = standartDateFormatter.dateFromString("6/9/15")
        var result = timeMachine.startDateForPeriod(.LastMonth, sinceDate: referenceDate!)
        XCTAssertEqual(result, checkDate!, "Last month has to be June")
        
        referenceDate = standartDateFormatter.dateFromString("1/1/15")
        checkDate = standartDateFormatter.dateFromString("12/1/14")
        result = timeMachine.startDateForPeriod(.LastMonth, sinceDate: referenceDate!)
        XCTAssertEqual(result, checkDate!, "Last month has to be December")
    }
    
    func testNumberOfDaysInPeriod() {
        let referenceDate = standartDateFormatter.dateFromString("7/9/15")
        let result = timeMachine.numberOfDaysInPeriod(.LastMonth, fromDate: referenceDate!)
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
    
    func testBusyDaysForPeriod() {
        let referenceDate = standartDateFormatter.dateFromString("7/9/15")!
        testActivity.basis = Activity.basisWithEnum(.Weekends)
//        testActivity.busyDays = Activity.defaultBusyDaysForBasis(testActivity.activityBasis())
        let daysInPeriod = testActivity.stats.busyDaysForPeriod(.LastMonth, sinceDate: referenceDate)
        XCTAssertEqual(daysInPeriod, 8, "4 Saturdays and 4 Sundays")
    }
    
    
    
    

}
