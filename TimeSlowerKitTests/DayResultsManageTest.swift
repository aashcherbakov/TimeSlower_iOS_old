//
//  DayResultsManageTest.swift
//  TimeSlower2
//
//  Created by Aleksander Shcherbakov on 7/2/15.
//  Copyright (c) 2015 1lastDay. All rights reserved.
//

import UIKit
import XCTest
import CoreData
import TimeSlowerKit

class DayResultsManageTest: XCTestCase {
    
    var testCoreDataStack: TestCoreDataStack!
    var testContext: NSManagedObjectContext!
    var testProfile: Profile!
    var testActivity: Activity!
    var testActivityStats: Stats!
    var testActivityTiming: Timing!
    var testResult: DayResults!
    var fakeWeekResults: [DayResults]!

    override func setUp() {
        super.setUp()
        // CoreDataStack
        testCoreDataStack = TestCoreDataStack()
        testContext = testCoreDataStack.managedObjectContext
        
        // Creating fake instances
        testProfile = testCoreDataStack.fakeProfile()
        testActivity = testCoreDataStack.fakeActivityWithProfile(testProfile, type: .Routine, basis: .Daily)
        testCoreDataStack.saveContext()
        testActivityTiming = testActivity.timing
        testActivityStats = testActivity.stats
        testResult = testCoreDataStack.fakeResultForActivity(testActivity)
    }
    
    override func tearDown() {
        testCoreDataStack.managedObjectContext!.deleteObject(testProfile)
        testCoreDataStack.managedObjectContext!.deleteObject(testResult)
        testCoreDataStack.managedObjectContext!.deleteObject(testActivity)
        testCoreDataStack.managedObjectContext!.deleteObject(testActivityStats)
        testCoreDataStack.managedObjectContext!.deleteObject(testActivityTiming)
        
        testCoreDataStack = nil
        super.tearDown()
    }
    
    func testCreation() {
        XCTAssertNotNil(testResult.date, "Date should not be nil")
        XCTAssertNotNil(testResult.factSuccess, "Fact success should not be nil")
        XCTAssertNotNil(testResult.factStartTime, "Fact start time should not be nil")
        XCTAssertNotNil(testResult.factFinishTime, "Fact finish time should not be nil")
        XCTAssertEqual(testResult.activity, testActivity, "Activities should be the same")
    }
    
    func testDaySuccess() {
        // setup timing
        setDefaultSettingsForDayResult()
        
        // for goal
        testActivity.type = Activity.typeWithEnum(.Goal)
        XCTAssertEqual(testResult.daySuccess(), 77.0, "Goal success must be 77%")
        
        // for routine
        testActivity.type = Activity.typeWithEnum(.Routine)
        XCTAssertEqual(testResult.daySuccess(), 70.0, "Routine success must be 70%")
    }
    
    /// Fact duration must be 23 min
    func setDefaultSettingsForDayResult() {
        let factStartTime = testCoreDataStack.shortStyleDateFormatter().dateFromString("7/3/15, 10:17 AM")!
        let factFinishTime = testCoreDataStack.shortStyleDateFormatter().dateFromString("7/3/15, 10:40 AM")!
        testResult.factFinishTime = Timing.updateTimeForToday(factFinishTime)
        testResult.factStartTime = Timing.updateTimeForToday(factStartTime)
        print("Finish time for result: \(testResult.factFinishTime)")
        print("Start time for result: \(testResult.factStartTime)")

    }

    func testFactSpentTime() {
        setDefaultSettingsForDayResult()
        XCTAssertEqual(testResult.factSpentTime(), 23.0, "Fact spent time must be 23 min")
    }
    
    func testFactSavedTime() {
        setDefaultSettingsForDayResult()
        XCTAssertEqual(testResult.factSavedTime!.doubleValue, 7.0, "Fact saved time must be 7 min")
    }
    
    func testCompareDatesOfResults() {
        // create additional result to compare
        let earlierDate = NSDate().dateByAddingTimeInterval(-60*60*24*4)
        testResult.date = DayResults.standardDateFormatter().stringFromDate(earlierDate)
        let additionalResult = DayResults.newResultWithDate(NSDate(), forActivity: testActivity)
        testCoreDataStack.saveContext()
        
        // compare
        let compareResult = testResult.compareDatesOfResults(additionalResult)
        XCTAssertEqual(compareResult.rawValue, NSComparisonResult.OrderedAscending.rawValue, "Additional result should be earlier than test result")
        
        // delete additional result
        testResult.managedObjectContext?.deleteObject(additionalResult)
    }
    
    
    func testShortDayNameForDate() {
        testResult.date = "7/5/15"
        let dayName = testResult.shortDayNameForDate()
        XCTAssertEqual(dayName, "Sun", "Short day name should be Sun")
        
        testResult.date = "7/10/15"
        let newDayName = testResult.shortDayNameForDate()
        XCTAssertEqual(newDayName, "Fri", "Short day name should be Fri")
        XCTAssertNotEqual(newDayName, "Sun", "Short day name should not be Sun")
    }
    
    func testLastWeekResultsForActivity() {
        createFakeResultsInNumberOf(5)
        XCTAssertEqual(fakeWeekResults.count, 5, "There should be 5 fake results in array")
        let lastWeekResults = DayResults.lastWeekResultsForActivity(testActivity)
        XCTAssertEqual(lastWeekResults.count, 6, "There should be 6 results")
        deleteFakeWeekResults()
    }
    
    func testFetchResultWithDate() {
        let fetchedResult = DayResults.fetchResultWithDate(NSDate(), forActivity: testResult.activity)
        XCTAssertEqual(fetchedResult!, testResult, "Results should be equal")
        
        let nonExistingResultDate = DayResults.standardDateFormatter().dateFromString("1/2/13")
        let nonExistingResult = DayResults.fetchResultWithDate(nonExistingResultDate!, forActivity: testResult.activity)
        XCTAssertNil(nonExistingResult, "Non existing result should be nil")
    }
    
    //MARK: - Helper functions
    func createFakeResultsInNumberOf(number: Int) {
        var results = [DayResults]()
        let originalResultDate = DayResults.standardDateFormatter().dateFromString(testResult.date)
        let dayTimeInterval: Double = 60*60*24
        for i in 1 ..< number + 1 {
            let newResultDate = originalResultDate?.dateByAddingTimeInterval(-dayTimeInterval * Double(i))
            results.append(DayResults.newResultWithDate(newResultDate!, forActivity: testResult.activity))
        }
        fakeWeekResults = results
        print(results)
    }
    
    func deleteFakeWeekResults() {
        for result in fakeWeekResults {
            testResult.managedObjectContext?.deleteObject(result)
        }
        testCoreDataStack.saveContext()
    }
    
    /// Converts dates with format: "7/3/15, 10:15 AM"
    func shortStyleDateFormatter() -> NSDateFormatter {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .ShortStyle
        dateFormatter.timeStyle = .ShortStyle
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        return dateFormatter
    }
}
