//
//  ProfileManageActivitiesTest.swift
//  TimeSlower2
//
//  Created by Aleksander Shcherbakov on 7/3/15.
//  Copyright (c) 2015 1lastDay. All rights reserved.
//

import UIKit
import XCTest
import CoreData
import TimeSlowerKit

class ProfileManageActivitiesTest: XCTestCase {

    var testCoreDataStack: TestCoreDataStack!
    var testContext: NSManagedObjectContext!
    
    var testProfile: Profile!
    var testActivity: Activity!
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
    
    
    //MARK: - Getting activities for name or date
    func testActivityForName() {
        let summonedActivity = testProfile.activityForName("Morning shower")
        XCTAssertNotNil(summonedActivity, "Activity should not be nil")
        XCTAssertEqual(summonedActivity!.name, "Morning shower", "Activity name must be Morning shower")
    }
    
    func testActivitiesForDateOnDailyActivities() {
        let activitiesForToday = testProfile.activitiesForDate(NSDate())
        XCTAssertEqual(activitiesForToday.count, 1, "There should be one activity")
        XCTAssertEqual(activitiesForToday.first!, testActivity, "Activities should be equal")
    }
    
    func testActivitiesForDateOnWeekendBasis() {
        testActivity.basis = Activity.basisWithEnum(.Weekends)
        let weekendDate = DayResults.standardDateFormatter().dateFromString("7/4/15")
        let activitiesForToday = testProfile.activitiesForDate(weekendDate!)

        XCTAssertEqual(activitiesForToday.count, 1, "There should be one activity")
        XCTAssertEqual(activitiesForToday.first!, testActivity, "Activities should be equal")
    }
    
    func testActivitiesForDateOnWorkdayBasis() {
        testActivity.basis = Activity.basisWithEnum(.Workdays)
        let workdayDate = DayResults.standardDateFormatter().dateFromString("7/6/15")
        let activitiesForToday = testProfile.activitiesForDate(workdayDate!)
        
        XCTAssertEqual(activitiesForToday.count, 1, "There should be one activity")
        XCTAssertEqual(activitiesForToday.first!, testActivity, "Activities should be equal")
    }
    
    func testActivitiesForDateOnWorkdayBasisFalse() {
        testActivity.basis = Activity.basisWithEnum(.Weekends)
        let workdayDate = DayResults.standardDateFormatter().dateFromString("7/6/15")
        let activitiesForToday = testProfile.activitiesForDate(workdayDate!)
        XCTAssertEqual(activitiesForToday.count, 0, "There should be no activities")
    }
    
    //MARK: - Getting activities for weekday

//    func testActivitiesForWeekdayWeekendBasisOnSaturday() {
//        testActivity.basis = Activity.basisWithEnum(.Weekends)
//        let activitiesForWeekday = testProfile.activitiesForWeekday(.Saturday)
//        XCTAssertEqual(activitiesForWeekday.count, 1, "There should be one activity")
//        XCTAssertEqual(activitiesForWeekday.first!, testActivity, "Activities should be equal")
//    }
//    
//    func testActivitiesForWeekdayDailyBasisOnSaturday() {
//        // test if daily basis counts on saturday
//        let activitiesForWeekday = testProfile.activitiesForWeekday(.Saturday)
//        XCTAssertEqual(activitiesForWeekday.count, 1, "There should be one activity")
//        XCTAssertEqual(activitiesForWeekday.first!, testActivity, "Activities should be equal")
//    }
//
//    func testActivitiesForWeekdayWorkdayBasisOnSaturday() {
//        testActivity.basis = Activity.basisWithEnum(.Workdays)
//        let activitiesForWeekday = testProfile.activitiesForWeekday(.Saturday)
//        XCTAssertEqual(activitiesForWeekday.count, 0, "There should be one activity")
//    }
    
    
    //MARK: - Testing time interval for availability
    func testIsTimeIntervalFreeFalse() {
        let testDateFormatter = testCoreDataStack.shortStyleDateFormatter()
        let testStart = testDateFormatter.dateFromString("7/5/15, 10:30 AM")
        let testFinish = testDateFormatter.dateFromString("7/5/15, 10:45 AM")
        let preventingActivity = testProfile.isTimeIntervalFree(startTime: testStart!, finish: testFinish!, basis: .Daily)
        XCTAssertNotNil(preventingActivity, "Time should not be free")
    }
    
    func testIsTimeIntervalFreeTrue() {
        let testDateFormatter = testCoreDataStack.shortStyleDateFormatter()
        let testStart = testDateFormatter.dateFromString("7/5/15, 10:50 AM")
        let testFinish = testDateFormatter.dateFromString("7/5/15, 11:45 AM")
        let preventingActivity = testProfile.isTimeIntervalFree(startTime: testStart!, finish: testFinish!, basis: .Daily)
        XCTAssertNil(preventingActivity, "Time should be free")
    }
    
    func testIsTimeIntervalFreeOnDifferentBasis() {
        testActivity.basis = Activity.basisWithEnum(.Workdays)
        let testDateFormatter = testCoreDataStack.shortStyleDateFormatter()
        let testStart = testDateFormatter.dateFromString("7/5/15, 10:30 AM")
        let testFinish = testDateFormatter.dateFromString("7/5/15, 10:45 AM")
        let preventingActivity = testProfile.isTimeIntervalFree(startTime: testStart!, finish: testFinish!, basis: .Daily)
        XCTAssertNotNil(preventingActivity, "Time should NOT be free")
    }
    
    func testIsTimeIntervalFreeWithOneMunuteClose() {
        let testDateFormatter = testCoreDataStack.shortStyleDateFormatter()
        let testStart = testDateFormatter.dateFromString("7/5/15, 10:45 AM")
        let testFinish = testDateFormatter.dateFromString("7/5/15, 11:45 AM")
        let preventingActivity = testProfile.isTimeIntervalFree(startTime: testStart!, finish: testFinish!, basis: .Daily)
        XCTAssertNil(preventingActivity, "Time should not be free")
    }
    
    func testCheckTimeIntervalForActivity() {
        let testStart = testDateFormatter.dateFromString("7/5/15, 10:30 AM")!
        let testFinish = testDateFormatter.dateFromString("7/5/15, 10:45 AM")!
        let preventing = testProfile.checkTimeIntervalForActivity(testActivity, testedStart: testStart, testedFinish: testFinish)
        XCTAssertNotNil(preventing, "There should be a preventing activity")
    }
    
    func testCheckTimeIntervalForActivityFalse() {
        let testStart = testDateFormatter.dateFromString("7/5/15, 10:50 AM")!
        let testFinish = testDateFormatter.dateFromString("7/5/15, 11:45 AM")!
        let preventing = testProfile.checkTimeIntervalForActivity(testActivity, testedStart: testStart, testedFinish: testFinish)
        XCTAssertNil(preventing, "Time interval should be free")
    }
    
    //MARK: - Sorting
    func testSortActivitiesByTime() {
        let newActivity = newTestActivity()
        let sortedArray = testProfile.sortActivitiesByTime([newActivity, testActivity])
        XCTAssertEqual(sortedArray[0], testActivity, "First should be old activity")
    }
    
    func testSortByNextActionTime() {
        let newActivity = newTestActivity()
        let sortingRestult = testProfile.sortByNextActionTime(testActivity, activity2: newActivity)
        XCTAssertTrue(sortingRestult, "First activity should be earlier")
    }
    
    func newTestActivity() -> Activity {
        let newActivity = testCoreDataStack.fakeActivityWithProfile(testProfile, type: .Routine, basis: .Daily)
        newActivity.name = "Second activity"
        newActivity.timing.startTime = testDateFormatter.dateFromString("7/5/15, 10:50 AM")!
        newActivity.timing.finishTime = testDateFormatter.dateFromString("7/5/15, 11:45 AM")!
        return newActivity
    }
    
    //MARK: - Current and closest activity
    func testFindCurrentActivity() {
        testActivity.timing.startTime = NSDate().dateByAddingTimeInterval(-60*5)
        testActivity.timing.finishTime = testActivity.timing.startTime.dateByAddingTimeInterval(60*30)
        
        let secondActivity = newTestActivity()
        secondActivity.timing.startTime = NSDate().dateByAddingTimeInterval(-60*60*5)
        secondActivity.timing.finishTime = NSDate().dateByAddingTimeInterval(-60*60*4)
        
        let currentActivity = testProfile.findCurrentActivity()
        XCTAssertEqual(currentActivity!, testActivity, "Test activity should be the current one")
    }
    
    func testFindCurrentActivityThatTriggersNextClosestActivity() {
        testActivity.timing.startTime = NSDate().dateByAddingTimeInterval(-60*60*5)
        testActivity.timing.finishTime = NSDate().dateByAddingTimeInterval(-60*60*4)
                
        let secondActivity = newTestActivity()
        secondActivity.timing.startTime = NSDate().dateByAddingTimeInterval(60*60*3)
        secondActivity.timing.finishTime = NSDate().dateByAddingTimeInterval(60*60*4)

        let currentActivity = testProfile.findCurrentActivity()
        XCTAssertEqual(currentActivity!, secondActivity, "Second activity should be the current one")
    }
    
    func testNextClosestActivityInTodayList() {
        testActivity.finishWithResult()

        let secondActivity = newTestActivity()
        secondActivity.timing.startTime = NSDate().dateByAddingTimeInterval(60*60*1)
        secondActivity.timing.finishTime = NSDate().dateByAddingTimeInterval(60*60*2)
        
        let nextActivity = testProfile.findNextActivityForToday()
        XCTAssertEqual(nextActivity!, secondActivity, "Second activity should be the next one")
    
    }
    
    func testNextClosestActivityInTomorrowList() {
        testActivity.finishWithResult()
        
        let secondActivity = newTestActivity()
        secondActivity.timing.startTime = testActivity.timing.startTime.dateByAddingTimeInterval(60*60*3)
        secondActivity.timing.finishTime = testActivity.timing.startTime.dateByAddingTimeInterval(60*60*4)
        secondActivity.finishWithResult()
        
        let nextActivity = testProfile.findNextActivityInTomorrowList()
        XCTAssertEqual(nextActivity!, testActivity, "Test activity should be the next one")
    }
    
    func testHasGoalsFalse() {
        XCTAssertFalse(testProfile.hasGoals(), "Test profile has no goals")
    }
    
    func testHasGoalsTrue() {
        testActivity.type = Activity.typeWithEnum(.Goal)
        XCTAssertNotNil(testProfile.hasGoals(), "Test profile must have goals")
    }
    
    func testGoalsForTodayFalse() {
        let goalsForToday = testProfile.goalsForToday()
        XCTAssertEqual(goalsForToday.count, 0, "There should be no goals for today")
    }
    
    func testGoalsForTodayTrue() {
        testActivity.type = Activity.typeWithEnum(.Goal)
        let goalsForToday = testProfile.goalsForToday()
        XCTAssertEqual(goalsForToday.count, 1, "There should be one goal for today")
    }
}
