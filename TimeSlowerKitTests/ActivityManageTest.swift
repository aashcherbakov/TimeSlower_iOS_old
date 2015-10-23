//
//  ActivityManageTest.swift
//  TimeSlower2
//
//  Created by Aleksander Shcherbakov on 6/25/15.
//  Copyright (c) 2015 1lastDay. All rights reserved.
//

import UIKit
import XCTest
import CoreData
import TimeSlowerKit

class ActivityManageTest: XCTestCase {

    var testCoreDataStack: TestCoreDataStack!
    var testContext: NSManagedObjectContext!
    
    var testProfile: Profile!
    var testActivity: Activity!
    var testActivityForDeletion: Activity!
    var testActivityStats: Stats!
    var testActivityTiming: Timing!

    var expectation: XCTestExpectation!
    
    var shortDateFormatter: NSDateFormatter!
    
    
    //MARK: - Setup
    
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
        
        shortDateFormatter = testCoreDataStack.shortStyleDateFormatter()
    }
    
    override func tearDown() {
        testCoreDataStack.managedObjectContext!.deleteObject(testProfile)
        testCoreDataStack.managedObjectContext!.deleteObject(testActivity)
        testCoreDataStack.managedObjectContext!.deleteObject(testActivityStats)
        testCoreDataStack.managedObjectContext!.deleteObject(testActivityTiming)
        
        testCoreDataStack = nil
        super.tearDown()
    }
    
    func testPersistantStoreType() {
        let persistentStore = testCoreDataStack.persistentStoreCoordinator!.persistentStores.first
        XCTAssertEqual(persistentStore!.type, "InMemory", "Persistant store should be of type InMemory")
    }

    //MARK: - Delete and Create activity
    
    func testActivityCreation() {
        XCTAssertNotNil(testActivity, "Activity should not be nil")
        XCTAssertNotNil(testActivityStats, "Timing should not be nil")
        XCTAssertNotNil(testActivityTiming, "Stats should not be nil")
        XCTAssertEqual(testActivity.activityType(), ActivityType.Routine, "Activity type should be routine")
        XCTAssertEqual(testActivity.profile, testProfile, "Profiles not the same")
        XCTAssertEqual(testActivity.name, "Morning shower", "Name should be Morning shower")
        XCTAssertGreaterThan(fakeFetchRequest().count, 0, "Fetch request failed")
    }
    
    
    func testDeleteActivity() {
        expectation = self.expectationForNotification(NSManagedObjectContextDidSaveNotification,
            object: testCoreDataStack.managedObjectContext) {
            notification in
            return true
        }
        
        let testActivityName = "Super name"
        testActivityForDeletion = Activity.newActivityForProfile(testProfile, ofType: .Routine)
        testActivityForDeletion.name = testActivityName
        XCTAssertNotNil(testProfile.activityForName(testActivityName), "Activity should be present")
        
        testCoreDataStack.managedObjectContext!.deleteObject(testActivityForDeletion)
        testCoreDataStack.saveContext()
        
        self.waitForExpectationsWithTimeout(2.0) {
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
        XCTAssertEqual(testActivity.basis.integerValue, ActivityBasis.Weekends.rawValue, "Basis should be Weekends")
    }
    
    func testSetBasisWithEnum() {
        testActivity.type = Activity.typeWithEnum(.Goal)
        XCTAssertEqual(testActivity.type.integerValue, ActivityType.Goal.rawValue, "Basis should be Weekends")
    }
    
    func testActivityBasisDescription() {
        XCTAssertEqual(testActivity.activityBasisDescription(), "Daily", "Basis should be spelled as Daily")
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
    
    func testCompareBasedOnNextActionTime() {
        let activityGoingNow = testCoreDataStack.fakeActivityWithProfile(testProfile, type: .Routine, basis: .Daily)
        activityGoingNow.timing.startTime = shortDateFormatter.dateFromString("7/5/15, 12:30 PM")!
        activityGoingNow.timing.finishTime = shortDateFormatter.dateFromString("7/5/15, 12:45 PM")!
        activityGoingNow.timing.updateDuration()
        
        let comparingToGoingNow = testActivity.compareBasedOnNextActionTime(activityGoingNow)
        XCTAssertEqual(comparingToGoingNow.rawValue, NSComparisonResult.OrderedAscending.rawValue, "Comparison result should be ascending")
        
    }
    
    func testCompareBasedOnNextActionTimeDescending() {
        let activityInFuture = testCoreDataStack.fakeActivityWithProfile(testProfile, type: .Routine, basis: .Daily)
        activityInFuture.timing.startTime = testActivity.timing.startTime.dateByAddingTimeInterval(60*60*4)
        activityInFuture.timing.finishTime = testActivity.timing.startTime.dateByAddingTimeInterval(60*60*5)
        activityInFuture.timing.updateDuration()

        let comparingToFuture = activityInFuture.compareBasedOnNextActionTime(testActivity)

        XCTAssertEqual(comparingToFuture.rawValue, NSComparisonResult.OrderedAscending.rawValue, "Comparison result should be ascending")
    }
}
