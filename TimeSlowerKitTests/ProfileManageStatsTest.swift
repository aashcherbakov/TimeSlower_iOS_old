//
//  ProfileManageStatsTest.swift
//  TimeSlower2
//
//  Created by Aleksander Shcherbakov on 7/3/15.
//  Copyright (c) 2015 1lastDay. All rights reserved.
//

import UIKit
import XCTest
import CoreData
import TimeSlowerKit

class ProfileManageStatsTest: XCTestCase {

    var testCoreDataStack: TestCoreDataStack!
    var testContext: NSManagedObjectContext!
    
    var testProfile: Profile!
    var testActivity: Activity!
    var testResult: DayResults!
    var testActivityForDeletion: Activity!
    var testActivityStats: Stats!
    var testActivityTiming: Timing!
    
    var testDateFormatter: NSDateFormatter!
    
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
        testCoreDataStack.saveContext()
        
        testDateFormatter = testCoreDataStack.shortStyleDateFormatter()
    }
    
    override func tearDown() {
        testCoreDataStack = nil
        testContext = nil
        testProfile = nil
        testActivity = nil
        testDateFormatter = nil
        super.tearDown()
    }
    
    
    func testUserProfileInManagedContext() {
        XCTAssertEqual(testProfile.birthday, DayResults.standardDateFormatter().dateFromString("3/28/87")!, "Default birthday should be 28 of march")
        XCTAssertEqual(testProfile.country, "United States", "Default country should be US")
        XCTAssertEqual(testProfile.gender, Profile.genderWithEnum(.Male), "Default gender is male")
        XCTAssertNotNil(testProfile.dateOfDeath, "Date of death should not be nil")
    }
    
    func testDefaultBirthday() {
        XCTAssertEqual(testProfile.birthday, DayResults.standardDateFormatter().dateFromString("3/28/87")!, "Default birthday should be 28 of march")
    }
    
    func testDefaultCountry() {
        XCTAssertEqual(testProfile.country, "United States", "Default country should be US")
    }
    
    func testFetchProfile() {
        XCTAssertNotNil(testCoreDataStack.fetchProfile(), "Fetch profile should not return nil")
    }
    
    func testUserAge() {
        XCTAssertEqual(testProfile.userAge(), 28, "User age must be 28 !!! TILL MARCH 2016")
    }
    
    func testUserGender() {
        XCTAssertEqual(testProfile.userGender(), Profile.Gender.Male, "User gender should be male")
    }
    
    func testUserGenderString() {
        XCTAssertEqual(testProfile.userGenderString(), "Male", "User gender should be male")
    }
    
    func testGenderWithEnum() {
        testProfile.gender = Profile.genderWithEnum(.Female)
        XCTAssertEqual(testProfile.gender, 1, "Gender must change to female")
    }
    
    func testYearsLeftForProfile() {
        XCTAssertGreaterThan(testProfile.yearsLeftForProfile(), 48, "Years left should be more than 48")
    }
    
    func testMaxYearsLeftForProfile() {
        XCTAssertEqual(testProfile.maxYearsForProfile(), 77.4, "Max years should be 77.4")
    }
    
    func testDateOfApproximateLifeEnd() {
        let dateOfDeathString = DayResults.standardDateFormatter().stringFromDate(testProfile.dateOfApproximateLifeEnd())
        XCTAssertEqual(dateOfDeathString, "3/28/64", "Date of death should be March 2064")
    }
    
    //MARK: - Profile global saving/spending stats
    
    func testTimeStatsForToday() {
        let dayStats = testProfile.timeStatsForPeriod(.Today)
        XCTAssertEqual(dayStats.factSaved, 7, "Today saving is 7 minutes")
        XCTAssertEqual(dayStats.factSpent, 0, "Today spendings is 0 minutes")
        XCTAssertEqual(dayStats.plannedToSave, 10, "Planned to save is 10 minutes")
        XCTAssertEqual(dayStats.plannedToSpend, 0, "No planned to spend time")
    }
    
    func testFactTimingForToday() {
        let newActivity = testCoreDataStack.fakeActivityWithProfile(testProfile, type: .Goal, basis: .Daily)
        newActivity.name = "Fake goal"
        _ = testCoreDataStack.fakeResultForActivity(newActivity)
        let factStats = testProfile.factTimingForPeriod(.Today)
        
        XCTAssertEqual(factStats.0, 7, "Today saving is 7 minutes")
        XCTAssertEqual(factStats.1, 23, "Today spendings is 23 minutes")
    }
    
    func testPlannedTimingForToday() {
        let newActivity = testCoreDataStack.fakeActivityWithProfile(testProfile, type: .Goal, basis: .Daily)
        newActivity.name = "Fake goal"
        let evenNewerGoal = testCoreDataStack.fakeActivityWithProfile(testProfile, type: .Goal, basis: .Daily)
        evenNewerGoal.name = "Even newer goal"
        let newFakeRoutine = testCoreDataStack.fakeActivityWithProfile(testProfile, type: .Routine, basis: .Daily)
        newFakeRoutine.name = "Fake routine"
        newFakeRoutine.timing.timeToSave = NSNumber(double: 15)
        let plannedStats = testProfile.plannedTimingInPeriod(.Today, sinceDate: NSDate())
        XCTAssertEqual(plannedStats.0, 25, "Today planned savings are 25 minutes")
        XCTAssertEqual(plannedStats.1, 60, "Today planned spendings are 60 minutes")
    }

    //MARK: - Minutes to lifetime conversion
    
    func testNumberOfDaysTillEndOfLife() {
        XCTAssertGreaterThan(testProfile.numberOfDaysTillEndOfLifeSinceDate(NSDate()), 17000, "Number of days must be greater than 17000")
    }
    
    func testTotalTimeForDailyMinutes() {
        let totalTime = testProfile.totalTimeForDailyMinutes(10)
        XCTAssertGreaterThan(totalTime.hours, 2500, "Number of hours must be greater than 2500")
        XCTAssertGreaterThan(totalTime.days, 100, "Number of days must be greater than 100")
        XCTAssertGreaterThan(totalTime.months, 3, "Number of months must be greater than 3")
        XCTAssertGreaterThan(totalTime.years, 0, "Number of years must be greater than 0")
    }

    
    
    //MARK: - - Last year
    
    func testSummSavedLastYear() {
        createFakeResultsForLastYear()
        let summ = testProfile.factTimingForPeriod(.LastYear)
        XCTAssertEqual(summ.0, 14, "Total 14 minutes")
        XCTAssertEqual(summ.1, 0, "Total spent 0 minutes")
    }
    
    func testTimePlannedToSaveLastYear() {
        let plannedToSaveLastYear = testProfile.plannedTimingInPeriod(.LastYear, sinceDate: NSDate())
        XCTAssertGreaterThan(plannedToSaveLastYear.0, 3600, "Last year planned to save 3600 hours")
    }
    
    
    //MARK: - - Last month
    
    func testTimeSavedLastMonth() {
        createFakeResultsForLastMonth()
        let summ = testProfile.factTimingForPeriod(.LastMonth)
        XCTAssertEqual(summ.0, 14, "Total 14 minutes")
    }
    
    func testTimePlannedToSaveLastMonth() {
        let plannedToSaveLastYear = testProfile.plannedTimingInPeriod(.LastMonth, sinceDate: NSDate())
        XCTAssertGreaterThan(plannedToSaveLastYear.0, 250, "Last year planned to save 250 hours")
    }
    
    
    
    
    func testDateBasedFetchRequestForLastYear() {
        createFakeResultsForLastYear()
        let result = testActivity.stats.allResultsForPeriod(.LastYear)
        XCTAssertEqual(result.count, 2, "Only 2 results for last year")
        XCTAssertEqual(testActivity.results.count, 3, "Activity must have 3 results")
    }
    
    func testAllResultsForLastMonth() {
        createFakeResultsForLastMonth()
        let result = testActivity.stats.allResultsForPeriod(.LastMonth)
        XCTAssertEqual(result.count, 2, "Only 2 results for last month")
        XCTAssertEqual(testActivity.results.count, 3, "Activity must have 3 results")
    }
    
    //MARK: - Test additionsl methods
    func createFakeResultsForLastYear() {
        testResult.date = "1/1/15"
        let lastYearDate = LazyCalendar.startDateForPeriod(.LastYear, sinceDate: NSDate())
        
        let tooOldResult = testCoreDataStack.fakeResultForActivity(testActivity)
        tooOldResult.date = "5/4/14"
        tooOldResult.raughDate = lastYearDate.dateByAddingTimeInterval(-60*60*24*300)
        
        let secondResult = testCoreDataStack.fakeResultForActivity(testActivity)
        secondResult.date = "5/4/15"
        secondResult.raughDate = lastYearDate.dateByAddingTimeInterval(60*60*24*60)
    }
    
    func createFakeResultsForLastMonth() {
        let standartDateFormatter = DayResults.standardDateFormatter()
        testResult.date = standartDateFormatter.stringFromDate(NSDate().dateByAddingTimeInterval(-60*60*24*7))
        
        let tooOldResult = testCoreDataStack.fakeResultForActivity(testActivity)
        
        let tooOldDate = NSDate().dateByAddingTimeInterval(-60*60*24*50)
        tooOldResult.date = standartDateFormatter.stringFromDate(tooOldDate)
        tooOldResult.raughDate = tooOldDate
        
        let lastMonthDate = NSDate().dateByAddingTimeInterval(-60*60*24*10)
        let secondResult = testCoreDataStack.fakeResultForActivity(testActivity)
        
        secondResult.date = standartDateFormatter.stringFromDate(lastMonthDate)
        secondResult.raughDate = lastMonthDate
    }
    
    
    
    
    
    
    
    
    
    
    
    
    

    
}
