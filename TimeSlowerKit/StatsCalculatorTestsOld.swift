////
////  StatsCalculatorTests.swift
////  TimeSlower
////
////  Created by Oleksandr Shcherbakov on 8/28/16.
////  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
////
//
//import XCTest
//@testable import TimeSlowerKit
//
//class StatsCalculatorTests: CoreDataBaseTest {
//    
//    var testDateFormatter: DateFormatter!
//    var timeMachine: TimeMachine!
//    var testResult: Result!
//    
//    //MARK: - Setup
//    
//    override func setUp() {
//        super.setUp()
//        
//        testResult = testCoreDataStack.fakeResultForActivity(testActivity)
//        testDateFormatter = testCoreDataStack.shortStyleDateFormatter()
//        timeMachine = TimeMachine()
//    }
//    
//    override func tearDown() {
//        deleteFakeWeekResults()
//        testResult = nil
//        testDateFormatter = nil
//        timeMachine = nil
//        super.tearDown()
//    }
//
//
//    func test_factResultsInPeriod() {
//        // factTimingForPeriod(period: PastPeriod) -> (saved: Double, spent: Double)?
//    }
//
//    
//    func test_plannedResultsInPeriod() {
//        // plannedTimingInPeriod(period: PastPeriod, sinceDate date: NSDate) -> (save: Double, spend: Double)? {
//    }
//    
//    func testTimeStatsForToday() {
//        let dayStats = testProfile.timeStatsForPeriod(.today)
//        XCTAssertEqual(dayStats.factSaved, 7, "Today saving is 7 minutes")
//        XCTAssertEqual(dayStats.factSpent, 0, "Today spendings is 0 minutes")
//        XCTAssertEqual(dayStats.plannedToSave, 10, "Planned to save is 10 minutes")
//        XCTAssertEqual(dayStats.plannedToSpend, 0, "No planned to spend time")
//    }
//    
//    func testFactTimingForToday() {
//        let newActivity = testCoreDataStack.fakeActivityWithProfile(testProfile, type: .goal, basis: .daily)
//        newActivity.name = "Fake goal"
//        _ = testCoreDataStack.fakeResultForActivity(newActivity)
//        let factStats = testProfile.factTimingForPeriod(.today)
//        
//        XCTAssertEqual(factStats!.0, 7, "Today saving is 7 minutes")
//        XCTAssertEqual(factStats!.1, 23, "Today spendings is 23 minutes")
//    }
//    
//    func testPlannedTimingForToday() {
//        let newActivity = testCoreDataStack.fakeActivityWithProfile(testProfile, type: .goal, basis: .daily)
//        newActivity.name = "Fake goal"
//        let evenNewerGoal = testCoreDataStack.fakeActivityWithProfile(testProfile, type: .goal, basis: .daily)
//        evenNewerGoal.name = "Even newer goal"
//        let newFakeRoutine = testCoreDataStack.fakeActivityWithProfile(testProfile, type: .routine, basis: .daily)
//        newFakeRoutine.name = "Fake routine"
//        newFakeRoutine.timing.timeToSave = NSNumber(value: 15 as Double)
//        let plannedStats = testProfile.plannedTimingInPeriod(.today, sinceDate: Date())
//        XCTAssertEqual(plannedStats!.0, 25, "Today planned savings are 25 minutes")
//        XCTAssertEqual(plannedStats!.1, 60, "Today planned spendings are 60 minutes")
//    }
//
//    //MARK: - - Last year
//    
//    func testSummSavedLastYear() {
//        createFakeResultsForLastYear()
//        let summ = testProfile.factTimingForPeriod(.lastYear)
//        XCTAssertEqual(summ!.0, 14, "Total 14 minutes")
//        XCTAssertEqual(summ!.1, 0, "Total spent 0 minutes")
//    }
//    
//    func testTimePlannedToSaveLastYear() {
//        let plannedToSaveLastYear = testProfile.plannedTimingInPeriod(.lastYear, sinceDate: Date())
//        XCTAssertGreaterThan(plannedToSaveLastYear!.0, 3600, "Last year planned to save 3600 hours")
//    }
//    
//    
//    //MARK: - - Last month
//    
//    func testTimeSavedLastMonth() {
//        createFakeResultsForLastMonth()
//        let summ = testProfile.factTimingForPeriod(.lastMonth)
//        XCTAssertEqual(summ!.0, 14, "Total 14 minutes")
//    }
//    
//    func testTimePlannedToSaveLastMonth() {
//        let plannedToSaveLastYear = testProfile.plannedTimingInPeriod(.lastMonth, sinceDate: Date())
//        XCTAssertGreaterThan(plannedToSaveLastYear!.0, 250, "Last year planned to save 250 hours")
//    }
//    
//    func testDateBasedFetchRequestForLastYear() {
//        createFakeResultsForLastYear()
//        let result = testActivity.unitTesting_allResultsForPeriod(.lastYear)
//        XCTAssertEqual(result.count, 2, "Only 2 results for last year")
//        XCTAssertEqual(testActivity.results!.count, 3, "Activity must have 3 results")
//    }
//    
//    func testAllResultsForLastMonth() {
//        createFakeResultsForLastMonth()
//        let result = testActivity.unitTesting_allResultsForPeriod(.lastMonth)
//        XCTAssertEqual(result.count, 2, "Only 2 results for last month")
//        XCTAssertEqual(testActivity.results!.count, 3, "Activity must have 3 results")
//    }
//    
//    
//    //MARK: - Test additionsl methods
//    func createFakeResultsForLastYear() {
//        testResult.date = "1/1/15"
//        let lastYearDate = timeMachine.startDateForPeriod(.lastYear, sinceDate: Date())
//        
//        let tooOldResult = testCoreDataStack.fakeResultForActivity(testActivity)
//        tooOldResult.date = "5/4/14"
//        tooOldResult.raughDate = lastYearDate.addingTimeInterval(-60*60*24*300)
//        
//        let secondResult = testCoreDataStack.fakeResultForActivity(testActivity)
//        secondResult.date = "5/4/15"
//        secondResult.raughDate = lastYearDate.addingTimeInterval(60*60*24*60)
//    }
//    
//    func createFakeResultsForLastMonth() {
//        let standartDateFormatter = Result.standardDateFormatter()
//        testResult.date = standartDateFormatter.string(from: Date().addingTimeInterval(-60*60*24*7))
//        
//        let tooOldResult = testCoreDataStack.fakeResultForActivity(testActivity)
//        
//        let tooOldDate = Date().addingTimeInterval(-60*60*24*50)
//        tooOldResult.date = standartDateFormatter.string(from: tooOldDate)
//        tooOldResult.raughDate = tooOldDate
//        
//        let lastMonthDate = Date().addingTimeInterval(-60*60*24*10)
//        let secondResult = testCoreDataStack.fakeResultForActivity(testActivity)
//        
//        secondResult.date = standartDateFormatter.string(from: lastMonthDate)
//        secondResult.raughDate = lastMonthDate
//    }
//    
//    func deleteFakeWeekResults() {
//        for activity in testProfile.allActivities() {
//            if let results = activity.results as? Set<Result> , results.count > 0 {
//                for result in results {
//                    testContext.delete(result)
//                }
//            }
//        }
//        
//        testCoreDataStack.saveContext()
//    }
//}
//
