////
////  ProfileManageActivitiesTest.swift
////  TimeSlower2
////
////  Created by Aleksander Shcherbakov on 7/3/15.
////  Copyright (c) 2015 1lastDay. All rights reserved.
////
//
//import UIKit
//import XCTest
//import CoreData
//@testable import TimeSlowerKit
//
//class ProfileManageActivitiesTest: CoreDataBaseTest {
//    
//    var testDateFormatter: DateFormatter!
//    
//    //MARK: - Setup
//    
//    override func setUp() {
//        super.setUp()
//        
//        testDateFormatter = testCoreDataStack.shortStyleDateFormatter()
//    }
//    
//    override func tearDown() {
//        super.tearDown()
//    }
//    
//    
//    //MARK: - Getting activities for name or date
//    
//    func testActivityForName() {
//        let summonedActivity = testProfile.activityForName("Morning shower")
//        XCTAssertNotNil(summonedActivity, "Activity should not be nil")
//        XCTAssertEqual(summonedActivity!.name, "Morning shower", "Activity name must be Morning shower")
//    }
//    
//    // MARK: - activitisForDate
//    
//    func testActivitiesForDateOnDailyActivities() {
//        let activitiesForToday = testProfile.activitiesForDate(Date())
//        XCTAssertEqual(activitiesForToday.count, 1, "There should be one activity")
//        XCTAssertEqual(activitiesForToday.first!, testActivity, "Activities should be equal")
//    }
//    
//    func testActivitiesForDateOnWeekendBasis() {
//        testActivity.days = [Day.createFromWeekday(Weekday(rawValue: 6)!, forActivity: testActivity)!]
//        let weekendDate = DayResults.standardDateFormatter().date(from: "7/4/15")
//        let activitiesForToday = testProfile.activitiesForDate(weekendDate!)
//
//        
//        XCTAssertEqual(activitiesForToday.count, 1, "There should be one activity")
//        XCTAssertEqual(activitiesForToday.first!, testActivity, "Activities should be equal")
//    }
//    
//    func testActivitiesForDateOnWorkdayBasis() {
//        testActivity.days = [Day.createFromWeekday(Weekday(rawValue: 1)!, forActivity: testActivity)!]
//        let workdayDate = DayResults.standardDateFormatter().date(from: "7/6/15")
//        let activitiesForToday = testProfile.activitiesForDate(workdayDate!)
//        
//        XCTAssertEqual(activitiesForToday.count, 1, "There should be one activity")
//        XCTAssertEqual(activitiesForToday.first!, testActivity, "Activities should be equal")
//    }
//    
//    func testActivitiesForDateOnWorkdayBasisFalse() {
//        testActivity.days = [Day.createFromWeekday(Weekday(rawValue: 0)!, forActivity: testActivity)!]
//        try! testContext.save()
//        
//        let workdayDate = DayResults.standardDateFormatter().date(from: "8/24/16")
//        let activitiesForToday = testProfile.activitiesForDate(workdayDate!)
//        XCTAssertEqual(activitiesForToday.count, 0, "There should be no activities")
//    }
//    
//    //MARK: - isTimeIntervalFree
//    
//    func testIsTimeIntervalFreeFalse() {
//        let testStart = testDateFormatter.date(from: "7/5/15, 10:30 AM")!
//        let testFinish = testDateFormatter.date(from: "7/5/15, 10:45 AM")!
//        let minutes = TimeMachine().minutesFromStart(testStart, toFinish: testFinish)
//        let duration = ActivityDuration(value: Int(minutes), period: .minutes)
//        let days = Weekday.weekdaysForBasis(.daily)
//        
//        let preventingActivity = testProfile.hasActivityScheduledToStart(testStart, duration: duration, days: days)
//        XCTAssertNotNil(preventingActivity, "Time should not be free")
//    }
//    
//    func testIsTimeIntervalFreeTrue() {
//        let testStart = testDateFormatter.date(from: "7/5/15, 10:50 AM")!
//        let testFinish = testDateFormatter.date(from: "7/5/15, 11:45 AM")!
//        let minutes = TimeMachine().minutesFromStart(testStart, toFinish: testFinish)
//        let duration = ActivityDuration(value: Int(minutes), period: .minutes)
//        let days = Weekday.weekdaysForBasis(.daily)
//        
//        let preventingActivity = testProfile.hasActivityScheduledToStart(testStart, duration: duration, days: days)
//        XCTAssertNil(preventingActivity, "Time should be free")
//    }
//    
//    func testIsTimeIntervalFreeOnDifferentBasis() {
//        testActivity.basis = Activity.basisWithEnum(.workdays)
//        let testStart = testDateFormatter.date(from: "7/5/15, 10:30 AM")!
//        let testFinish = testDateFormatter.date(from: "7/5/15, 10:45 AM")!
//        let minutes = TimeMachine().minutesFromStart(testStart, toFinish: testFinish)
//        let duration = ActivityDuration(value: Int(minutes), period: .minutes)
//        let days = Weekday.weekdaysForBasis(.daily)
//
//
//        let preventingActivity = testProfile.hasActivityScheduledToStart(testStart, duration: duration, days: days)
//        XCTAssertNotNil(preventingActivity, "Time should NOT be free")
//    }
//    
//    func testIsTimeIntervalFreeWithOneMunuteClose() {
//        let testStart = testDateFormatter.date(from: "7/5/15, 10:45 AM")!
//        let testFinish = testDateFormatter.date(from: "7/5/15, 11:45 AM")!
//        let minutes = TimeMachine().minutesFromStart(testStart, toFinish: testFinish)
//        let duration = ActivityDuration(value: Int(minutes), period: .minutes)
//        let days = Weekday.weekdaysForBasis(.daily)
//
//        let preventingActivity = testProfile.hasActivityScheduledToStart(testStart, duration: duration, days: days)
//        XCTAssertNil(preventingActivity, "Time should not be free")
//    }
//    
//    
//    func test_hasFreeTimeStarting_sameTime_sameDay() {
//        let result = testProfile.hasActivityScheduledToStart(testActivity.timing.startTime, duration: testActivity.timing.duration, days: Weekday.weekdaysFromSetOfDays(testActivity.days as! Set<Day>))
//        XCTAssertNotNil(result, "it should have preventing activity")
//    }
//    
//    func test_hasFreeTimeStarting_sameTime_differentDay() {
//        testActivity.days = Day.dayEntitiesFromSelectedDays([0, 6], forActivity: testActivity) as NSSet
//        let workdays = Weekday.weekdaysForBasis(.workdays)
//        let result = testProfile.hasActivityScheduledToStart(testActivity.timing.startTime, duration: testActivity.timing.duration, days: workdays)
//        XCTAssertNil(result, "it should not have preventing activity")
//    }
//    
//    //MARK: - Sorting
//    
//    func testSortActivitiesByTime() {
//        let newActivity = newTestActivity()
//        let sortedArray = testProfile.sortActivitiesByTime([newActivity, testActivity])
//        XCTAssertEqual(sortedArray[0], testActivity, "First should be old activity")
//    }
//    
//    func testSortByNextActionTime() {
//        let newActivity = newTestActivity()
//        let sortingRestult = testProfile.sortActivitiesByTime([testActivity, newActivity])
//        
//        XCTAssertEqual(sortingRestult.first, testActivity, "old activity should be earlier")
//    }
//    
//    
//    //MARK: - Current and closest activity
//    
//    func testFindCurrentActivity() {
//        testActivity.timing.startTime = Date().addingTimeInterval(-60*5)
//        testActivity.timing.finishTime = testActivity.timing.startTime.addingTimeInterval(60*30)
//        
//        let secondActivity = newTestActivity()
//        secondActivity.timing.startTime = Date().addingTimeInterval(-60*60*5)
//        secondActivity.timing.finishTime = Date().addingTimeInterval(-60*60*4)
//        
//        let currentActivity = testProfile.findCurrentActivity()
//        XCTAssertEqual(currentActivity!, testActivity, "Test activity should be the current one")
//    }
//    
//    func testFindCurrentActivityThatTriggersNextClosestActivity() {
//        testActivity.timing.startTime = Date().addingTimeInterval(-60*60*5)
//        testActivity.timing.finishTime = Date().addingTimeInterval(-60*60*4)
//                
//        let secondActivity = newTestActivity()
//        secondActivity.timing.startTime = Date().addingTimeInterval(60*60*3)
//        secondActivity.timing.finishTime = Date().addingTimeInterval(60*60*4)
//
//        let currentActivity = testProfile.findCurrentActivity()
//        XCTAssertEqual(currentActivity!, secondActivity, "Second activity should be the current one")
//    }
//    
//    func testNextClosestActivityInTodayList() {
//        testActivity.finishWithResult()
//
//        let secondActivity = newTestActivity()
//        secondActivity.timing.startTime = Date().addingTimeInterval(60*60*1)
//        secondActivity.timing.finishTime = Date().addingTimeInterval(60*60*2)
//        
//        let nextActivity = testProfile.findNextActivityForToday()
////        XCTAssertEqual(nextActivity!, secondActivity, "Second activity should be the next one")
//    
//    }
//    
//    func testNextClosestActivityInTomorrowList() {
//        testActivity.finishWithResult()
//        
//        let secondActivity = newTestActivity()
//        secondActivity.timing.startTime = testActivity.timing.startTime.addingTimeInterval(60*60*3)
//        secondActivity.timing.finishTime = testActivity.timing.startTime.addingTimeInterval(60*60*4)
//        secondActivity.finishWithResult()
//        
//        let nextActivity = testProfile.findNextActivityInTomorrowList()
//        XCTAssertEqual(nextActivity!, testActivity, "Test activity should be the next one")
//    }
//    
//    // MARK: - Has Goals
//    
//    func testHasGoalsFalse() {
//        XCTAssertFalse(testProfile.hasGoals(), "Test profile has no goals")
//    }
//    
//    func testHasGoalsTrue() {
//        testActivity.type = Activity.typeWithEnum(.goal)
//        XCTAssertNotNil(testProfile.hasGoals(), "Test profile must have goals")
//    }
//    
//    func testGoalsForTodayFalse() {
//        let goalsForToday = testProfile.goalsForToday()
//        XCTAssertEqual(goalsForToday.count, 0, "There should be no goals for today")
//    }
//    
//    func testGoalsForTodayTrue() {
//        testActivity.type = Activity.typeWithEnum(.goal)
//        let goalsForToday = testProfile.goalsForToday()
//        XCTAssertEqual(goalsForToday.count, 1, "There should be one goal for today")
//    }
//    
//    // MARK: - Helper Functions
//    
//    func newTestActivity() -> Activity {
//        let newActivity = testCoreDataStack.fakeActivityWithProfile(testProfile, type: .routine, basis: .daily)
//        newActivity.name = "Second activity"
//        newActivity.timing.startTime = testDateFormatter.date(from: "7/5/15, 10:50 AM")!
//        newActivity.timing.finishTime = testDateFormatter.date(from: "7/5/15, 11:45 AM")!
//        return newActivity
//    }
//}
