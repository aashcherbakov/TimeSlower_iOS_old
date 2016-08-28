//
//  ActivityTests.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 8/21/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import XCTest
import CoreData
import TimeSlowerKit

class ActivityTests: CoreDataBaseTest {
    
    var startTime: NSDate!
    var finishTime: NSDate!
    
    var updatedStartTime: NSDate!
    var updatedFinishTime: NSDate!
    
    var expectation: XCTestExpectation!
    var testActivityForDeletion: Activity!
    var dateFormatter: NSDateFormatter!
    
    override func setUp() {
        super.setUp()
        dateFormatter = StaticDateFormatter.shortDateAndTimeFormatter

        startTime = dateFormatter.dateFromString("7/8/15, 10:00 AM")!
        finishTime = dateFormatter.dateFromString("7/8/15, 10:30 AM")!
        updatedStartTime = dateFormatter.dateFromString("7/8/15, 11:00 AM")!
        updatedFinishTime = dateFormatter.dateFromString("7/8/15, 11:40 AM")!
        
    }
    
    override func tearDown() {
        startTime = nil
        finishTime = nil
        super.tearDown()
    }
    
    
    // MARK: - Creation
    
    func test_createRoutine() {
        let activity = coffeeRoutine()
        
        XCTAssertEqual(activity.type, 0, "it should be 0 for Routine")
        XCTAssertEqual(activity.profile, testProfile, "it should assign profile to which created")
        XCTAssertNotNil(activity.stats, "it should create default stats object")
        XCTAssertNotNil(activity.timing, "it should create default timing object")
        
        XCTAssertEqual(activity.name, "Coffee")
        XCTAssertEqual(activity.days.count, 3)
        XCTAssertEqual(activity.basis, 3, "it should set random basis")
        
        XCTAssertEqual(activity.timing.startTime, startTime)
        XCTAssertEqual(activity.timing.finishTime, finishTime)
        XCTAssertEqual(activity.timing.duration.minutes(), 30)
        XCTAssertEqual(activity.timing.timeToSave, 5)
        XCTAssertEqual(activity.notifications, 1)
        
        // TODO: update stats
    }
    
    // MARK: - Update Activity
    
    func test_updateActivityWithParameters() {
        // given

        let activity = coffeeRoutine()
        
        // when
        Activity.updateActivityWithParameters(activity,
          name: "Morning",
          selectedDays: [6, 0],
          startTime: updatedStartTime,
          duration: ActivityDuration(value: 40, period: .Minutes),
          notifications: false,
          timeToSave: 10)
        
        // then
        XCTAssertEqual(activity.type, 0, "it should be 0 for Routine")
        XCTAssertEqual(activity.profile, testProfile, "it should assign profile to which created")
        
        XCTAssertEqual(activity.name, "Morning")
        XCTAssertEqual(activity.days.count, 2)
        XCTAssertEqual(activity.basis, 2, "it should set weekend basis")
        
        XCTAssertEqual(activity.timing.startTime, updatedStartTime)
        XCTAssertEqual(activity.timing.finishTime, updatedFinishTime)
        XCTAssertEqual(activity.timing.duration.minutes(), 40)
        XCTAssertEqual(activity.timing.timeToSave, 10)
        XCTAssertEqual(activity.notifications, 0)
    }
    
    func testDeleteActivity() {
        expectation = self.expectationForNotification(
            NSManagedObjectContextDidSaveNotification,
                object: testCoreDataStack.managedObjectContext) {
                    notification in
                    return true
        }
        
        let testActivityName = "Super name"
        testActivityForDeletion = Activity.createActivityWithType(
            .Routine,
            name: "Morning shower",
            selectedDays: [1],
            startTime: dateFormatter.dateFromString("7/3/15, 10:15 AM")!,
            duration: ActivityDuration(value: 30, period: .Minutes),
            notifications: true,
            timeToSave: 10,
            forProfile: testProfile)
        
        testActivityForDeletion.name = testActivityName        
        testCoreDataStack.managedObjectContext!.deleteObject(testActivityForDeletion)
        testCoreDataStack.saveContext()
        
        waitForExpectationsWithTimeout(2.0) {
            [unowned self] error in
            XCTAssertNil(self.testProfile.activityForName(testActivityName), "Activity should be nil after deletion")
            self.testActivityForDeletion = nil
        }
    }
    
    func fakeFetchRequest() -> [Activity] {
        let request = NSFetchRequest(entityName: "Activity")
        request.predicate = NSPredicate(format: "name == %@", "Morning shower")
        return try! testContext.executeFetchRequest(request) as! [Activity]
    }
    
    func testSetTypeWithEnum() {
        testActivity.basis = Activity.basisWithEnum(.Weekends)
        XCTAssertEqual(testActivity.basis.integerValue, Basis.Weekends.rawValue, "Basis should be Weekends")
    }
    
    func testSetBasisWithEnum() {
        testActivity.type = Activity.typeWithEnum(.Goal)
        XCTAssertEqual(testActivity.type.integerValue, ActivityType.Goal.rawValue, "Basis should be Weekends")
    }
    
    func testBasisDescription() {
        XCTAssertEqual(testActivity.activityBasis().description(), "Every single day", "Basis should be spelled as Every single day")
    }
    
    func testFinishWithResult() {
        // Negative
        let result = DayResults.fetchResultWithDate(NSDate(), forActivity: testActivity)
        XCTAssertNil(result, "Activity is not finished so it should not have any results")
        
        // Positive
        testActivity.finishWithResult()
        let newResult = DayResults.fetchResultWithDate(NSDate(), forActivity: testActivity)
        XCTAssertNotNil(newResult, "Finished activity must have result")
    }
    
    // MARK: - Comparing activities
    
    func testCompareBasedOnNextActionTime() {
        // given
        let firstActivity = coffeeRoutine()
        let secondActivity = afterCoffeeRoutine()
        
        // when
        let comparingResult = firstActivity.compareBasedOnNextActionTime(secondActivity)
        
        // then
        XCTAssertEqual(comparingResult.rawValue, NSComparisonResult.OrderedAscending.rawValue, "Comparison result should be ascending")
    }
    
    func testCompareBasedOnNextActionTimeDescending() {
        // given
        let firstActivity = coffeeRoutine()
        let secondActivity = afterCoffeeRoutine()
        
        // when
        let comparingResult = secondActivity.compareBasedOnNextActionTime(firstActivity)
        
        // then
        XCTAssertEqual(comparingResult.rawValue, NSComparisonResult.OrderedDescending.rawValue, "Comparison result should be ascending")
    }
    
    func test_fitWeekday() {
        let weekday = Weekday(rawValue: 0)!
        XCTAssertTrue(testActivity.fitsWeekday(weekday), "it should fit Saturday as it's a daily activity")
    }
    
    func test_fitWeekdayNegative() {
        let weekday = Weekday(rawValue: 0)!
        let workdayActivity = testCoreDataStack.fakeActivityWithProfile(testProfile, type: .Routine, basis: .Workdays)
        XCTAssertFalse(workdayActivity.fitsWeekday(weekday), "it should not fit Saturday as it's a workdays only activity")
    }
    
    // MARK: - Occupies Time Between Start and Finish date
    
    func test_occupiesTimeBetween_Positive() {
        XCTAssertTrue(testActivity.occupiesTimeBetween(startTime, finish: finishTime),
                      "it should be occupied by test activity")
    }
    
    func test_occupiesTimeBetween_Positive_StartTimeIntersection() {
        XCTAssertTrue(testActivity.occupiesTimeBetween(startTime, finish: updatedFinishTime),
                      "it should be occupied by test activity")
    }
    
    func test_occupiesTimeBetween_Positive_FinishTimeIntersection() {
        XCTAssertTrue(testActivity.occupiesTimeBetween(finishTime, finish: updatedFinishTime),
                      "it should be occupied by test activity")
    }
    
    func test_occupiesTimeBetween_Negative() {
        XCTAssertFalse(testActivity.occupiesTimeBetween(updatedStartTime, finish: updatedFinishTime),
                      "it should not be occupied by test activity")
    }
    
    
    // MARK: - Helper functions
    
    private func coffeeRoutine() -> Activity {
        let activity = Activity.createActivityWithType(.Routine,
           name: "Coffee",
           selectedDays: [1, 2, 3],
           startTime: startTime,
           duration: ActivityDuration(value: 30, period: .Minutes),
           notifications: true,
           timeToSave: 5,
           forProfile: testProfile)
        return activity
    }
    
    private func afterCoffeeRoutine() -> Activity {
        let activity = Activity.createActivityWithType(.Routine,
            name: "After coffee",
            selectedDays: [1, 2, 3],
            startTime: updatedStartTime,
            duration: ActivityDuration(value: 30, period: .Minutes),
            notifications: true,
            timeToSave: 5,
            forProfile: testProfile)
        return activity
    }
}
