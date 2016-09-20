////
////  DayResultsTests.swift
////  TimeSlower
////
////  Created by Oleksandr Shcherbakov on 8/21/16.
////  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
////
//
//import XCTest
//@testable import TimeSlowerKit
//
//class DayResultsTests: CoreDataBaseTest {
//
//    var shortDateFormatter: DateFormatter!
//    var shortTimeFormatter: DateFormatter!
//    var testDateString: String!
//    var testStartDate: Date!
//    var testFinishDate: Date!
//    var sut: DayResults!
//    var fakeWeekResults: [DayResults]!
//
//    
//    override func setUp() {
//        super.setUp()
//        shortDateFormatter = StaticDateFormatter.shortDateNoTimeFromatter
//        shortTimeFormatter = StaticDateFormatter.shortDateAndTimeFormatter
//        testDateString = "8/21/16"
//        
//        testStartDate = shortTimeFormatter.date(from: "8/21/16, 10:15 AM")
//        testFinishDate = shortTimeFormatter.date(from: "8/21/16, 10:45 AM")
//        
//        sut = DayResults.newResultWithDate(testFinishDate, forActivity: testActivity)
//    }
//    
//    override func tearDown() {
//        testDateString = nil
//        deleteFakeWeekResults()
//        fakeWeekResults = nil
//        sut = nil
//        super.tearDown()
//    }
//
//    func test_createResult() {
//        let result = DayResults.newResultWithDate(testFinishDate, forActivity: testActivity)
//        let expectedStartTime = shortTimeFormatter.date(from: "8/21/16, 10:15 AM")!
//
//        XCTAssertNotNil(result)
//        XCTAssertEqual(result.activity, testActivity, "it should assign test activity as owner")
//        XCTAssertEqual(shortDateFormatter.string(from: result.raughDate), testDateString)
//        XCTAssertEqual(shortTimeFormatter.string(from: result.factFinishTime), "\(testDateString), 10:45 AM")
//        XCTAssertEqual(result.date, testDateString, "it should be 8/21/16")
//        XCTAssertEqual(result.factStartTime, expectedStartTime, "it should be 10:15 AM")
//        XCTAssertEqual(result.factDuration, 30, "it should be 95 minutes")
//        XCTAssertEqual(result.factSuccess, 0, "it should have 0 success since no time is saved")
//        XCTAssertEqual(result.factSavedTime, 0, "it should save 0 minutes")
//        XCTAssertNil(result.activity.timing.manuallyStarted, "it should set manually started to nil")
//    }
//    
//    func test_factDurationFromStartToFinish() {
//        let start = sut.factStartTime
//        let finish = sut.factFinishTime
//        XCTAssertEqual(shortTimeFormatter.string(from: start), "8/21/16, 10:15 AM")
//        XCTAssertEqual(shortTimeFormatter.string(from: finish), "8/21/16, 10:45 AM")
//        XCTAssertEqual(sut.factDuration, 30, "It should be 30 minutes")
//    }
//    
//    // MARK: - Success calculation for Routine
//    
//    func test_successForRoutine_noSuccess() {
//        let result = DayResults.successForRoutine(start: testStartDate, finish: testFinishDate, maxDuration: 30, goal: 10)
//        XCTAssertEqual(result, 0, "it should have no success at all")
//    }
//    
//    func test_successForRoutine_fullSuccess() {
//        let result = DayResults.successForRoutine(start: testStartDate, finish: testFinishDate, maxDuration: 40, goal: 10)
//        XCTAssertEqual(result, 100, "it should have 100% success")
//    }
//    
//    func test_successForRoutine_someSuccess() {
//        let result = DayResults.successForRoutine(start: testStartDate, finish: testFinishDate, maxDuration: 35, goal: 10)
//        XCTAssertEqual(result, 50, "it should have 50% success")
//    }
//    
//    func test_successForRoutine_superSuccess() {
//        let result = DayResults.successForRoutine(start: testStartDate, finish: testFinishDate, maxDuration: 50, goal: 10)
//        XCTAssertEqual(result, 200, "it should have 200% success")
//    }
//    
//    func test_successForRoutine_negativeSuccess() {
//        let result = DayResults.successForRoutine(start: testStartDate, finish: testFinishDate, maxDuration: 20, goal: 10)
//        XCTAssertEqual(result, 0, "it should have no success")
//    }
//    
//    // MARK: - Success calculation for Goal
//    
//    func test_successForGoal_fullSuccess() {
//        let result = DayResults.successForGoal(start: testStartDate, finish: testFinishDate, maxDuration: 30, goal: 10)
//        XCTAssertEqual(result, 100)
//    }
//    
//    func test_successForGoal_noSuccess() {
//        let result = DayResults.successForGoal(start: testStartDate, finish: testStartDate, maxDuration: 30, goal: 10)
//        XCTAssertEqual(result, 0)
//    }
//    
//    func test_successForGoal_superSuccess() {
//        let result = DayResults.successForGoal(start: testStartDate, finish: testFinishDate, maxDuration: 20, goal: 10)
//        XCTAssertEqual(result, 150)
//    }
//    
//    func testCompareDatesOfResults() {
//        // create additional result to compare
//        let earlierDate = Date().addingTimeInterval(-60*60*24*4)
//        sut.date = DayResults.standardDateFormatter().string(from: earlierDate)
//        let additionalResult = DayResults.newResultWithDate(Date(), forActivity: testActivity)
//        testCoreDataStack.saveContext()
//        
//        // compare
//        let compareResult = sut.compareDatesOfResults(additionalResult)
//        XCTAssertEqual(compareResult.rawValue, ComparisonResult.orderedAscending.rawValue, "Additional result should be earlier than test result")
//        
//        // delete additional result
//        sut.managedObjectContext?.delete(additionalResult)
//    }
//    
//    
//    func testShortDayNameForDate() {
//        sut.date = "7/5/15"
//        let dayName = sut.shortDayNameForDate()
//        XCTAssertEqual(dayName, "Sun", "Short day name should be Sun")
//        
//        sut.date = "7/10/15"
//        let newDayName = sut.shortDayNameForDate()
//        XCTAssertEqual(newDayName, "Fri", "Short day name should be Fri")
//        XCTAssertNotEqual(newDayName, "Sun", "Short day name should not be Sun")
//    }
//    
//    // MARK: - Fetching
//    
//    func testLastWeekResultsForActivity() {
//        createFakeResultsInNumberOf(5)
//        XCTAssertEqual(fakeWeekResults.count, 5, "There should be 5 fake results in array")
//        let lastWeekResults = DayResults.lastWeekResultsForActivity(testActivity)
//        XCTAssertEqual(lastWeekResults.count, 6, "There should be 6 results")
//        deleteFakeWeekResults()
//    }
//    
//    func testFetchResultWithDate() {
////        let fetchedResult = DayResults.fetchResultWithDate(testFinishDate, forActivity: sut.activity)
////        XCTAssertEqual(fetchedResult!, sut, "Results should be equal")
////        
////        let nonExistingResultDate = DayResults.standardDateFormatter().date(from: "1/2/13")
////        let nonExistingResult = DayResults.fetchResultWithDate(nonExistingResultDate!, forActivity: sut.activity)
////        XCTAssertNil(nonExistingResult, "Non existing result should be nil")
//    }
//    
//    //MARK: - Helper functions
//    func createFakeResultsInNumberOf(_ number: Int) {
//        var results = [DayResults]()
//        let originalResultDate = DayResults.standardDateFormatter().date(from: sut.date)
//        let dayTimeInterval: Double = 60*60*24
//        for i in 1 ..< number + 1 {
//            let newResultDate = originalResultDate?.addingTimeInterval(-dayTimeInterval * Double(i))
//            results.append(DayResults.newResultWithDate(newResultDate!, forActivity: sut.activity))
//        }
//        fakeWeekResults = results
//    }
//    
//    func deleteFakeWeekResults() {
//        if let results = fakeWeekResults , results.count > 0 {
//            for result in results {
//                sut.managedObjectContext?.delete(result)
//            }
//            testCoreDataStack.saveContext()
//        }
//    }
//}
