//
//  TimingManageTest.swift
//  TimeSlower2
//
//  Created by Aleksander Shcherbakov on 7/3/15.
//  Copyright (c) 2015 1lastDay. All rights reserved.
//

import UIKit
import XCTest
import CoreData
import TimeSlowerKit

class TimingManageTest: XCTestCase {

    var testCoreDataStack: TestCoreDataStack!
    var testContext: NSManagedObjectContext!
    var testProfile: Profile!
    var testActivity: Activity!
    
    var testActivityStats: Stats!
    var testActivityTiming: Timing!
    var standartDateFormatter: NSDateFormatter!
    
    override func setUp() {
        super.setUp()
        
        // CoreDataStack
        testCoreDataStack = TestCoreDataStack()
        testContext = testCoreDataStack.managedObjectContext
        standartDateFormatter = DayResults.standardDateFormatter()
        
        // Creating fake instances
        testProfile = testCoreDataStack.fakeProfile()
        testActivity = testCoreDataStack.fakeActivityWithProfile(testProfile, type: .Routine, basis: .Daily)
        testCoreDataStack.saveContext()
        
        testActivityTiming = testActivity.timing
        testActivityStats = testActivity.stats
    }
    
    override func tearDown() {
        testCoreDataStack.managedObjectContext!.deleteObject(testProfile)
        testCoreDataStack.managedObjectContext!.deleteObject(testActivity)
        testCoreDataStack.managedObjectContext!.deleteObject(testActivityStats)
        testCoreDataStack.managedObjectContext!.deleteObject(testActivityTiming)
        
        testCoreDataStack = nil
        super.tearDown()
    }
    
    func testCreation() {
        XCTAssertNotNil(testActivityTiming, "Timing should not be nil")
        XCTAssertTrue(testActivityTiming.respondsToSelector(Selector("updatedStartTime")), "Timing class")
        XCTAssertTrue(testActivityTiming.activity.respondsToSelector(Selector("isRoutine")), "Timing should have activity attached")
        
        let startTime = testCoreDataStack.shortStyleDateFormatter().dateFromString("7/3/15, 10:15 AM")!
        let finishTime = testCoreDataStack.shortStyleDateFormatter().dateFromString("7/3/15, 10:45 AM")!
        XCTAssertEqual(testActivityTiming.startTime, startTime, "Start time has to be 10:15")
        XCTAssertEqual(testActivityTiming.finishTime, finishTime, "Finish time has to be 10:45")
        XCTAssertEqual(testActivityTiming.duration, NSNumber(double: 30.0), "Duration has to be 30 min")
        XCTAssertEqual(testActivityTiming.timeToSave, NSNumber(double: 10.0), "Time to save has to be 10 min")
    }
    
    func testUpdateDureation() {
        let newStartTime = testCoreDataStack.shortStyleDateFormatter().dateFromString("7/3/15, 11:05 AM")!
        let newFinishTime = testCoreDataStack.shortStyleDateFormatter().dateFromString("7/3/15, 11:45 AM")!
        testActivityTiming.startTime = newStartTime
        testActivityTiming.finishTime = newFinishTime
        testActivityTiming.updateDuration()
        XCTAssertEqual(testActivityTiming.duration.doubleValue, 40.0, "Duration should be 40.0")
    }
    
    func testIsPassedDueForToday() {
        // Positive
        testActivityTiming.finishTime = NSDate().dateByAddingTimeInterval(-60*60)
        XCTAssertTrue(testActivityTiming.isPassedDueForToday(), "Avtivity should be passed due")
        
        // Negative
        testActivityTiming.finishTime = NSDate().dateByAddingTimeInterval(60*60)
        testActivityTiming.updateDuration()
        XCTAssertFalse(testActivityTiming.isPassedDueForToday(), "Avtivity should not be passed due")
    }
    
    func testFinishTimeIsNextDay() {
        let newStartTime = testCoreDataStack.shortStyleDateFormatter().dateFromString("7/3/15, 11:45 PM")!
        let newFinishTime = testCoreDataStack.shortStyleDateFormatter().dateFromString("7/4/15, 00:45 AM")!
        testActivityTiming.startTime = newStartTime
        testActivityTiming.finishTime = newFinishTime
        testActivityTiming.updateDuration()
        XCTAssertTrue(testActivityTiming.finishTimeIsNextDay(), "Finish time must be next day")
    }
    
    func testIsGoingNow() {
        // Positive
        testActivityTiming.startTime = NSDate().dateByAddingTimeInterval(-60*60)
        testActivityTiming.finishTime = NSDate().dateByAddingTimeInterval(60*60)
        testActivityTiming.updateDuration()
        XCTAssertTrue(testActivityTiming.isGoingNow(), "Activity should be going now")
        
        // Negative
        testActivityTiming.startTime = NSDate().dateByAddingTimeInterval(-60*60)
        testActivityTiming.finishTime = NSDate().dateByAddingTimeInterval(-20*60)
        testActivityTiming.updateDuration()
        XCTAssertFalse(testActivityTiming.isGoingNow(), "Activity should NOT be going now")
    }

    func testIsDoneForToday() {
        // Negative
        XCTAssertFalse(testActivity.isDoneForToday(), "Activity should not be done yet")
        
        // Positive
        testActivity.finishWithResult()
        XCTAssertTrue(testActivity.isDoneForToday(), "Activity should be done")
    }
    
    func testUpdateTimeForToday() {
        let twoDaysAgoDate = NSDate().dateByAddingTimeInterval(-60*60*24*2)
        let updatedDate = Timing.updateTimeForToday(twoDaysAgoDate)
        
        let oldDateComponents = NSCalendar.currentCalendar().components([.Hour, .Minute], fromDate: twoDaysAgoDate)
        let newDateComponents = NSCalendar.currentCalendar().components([.Month, .Day, .Year, .Hour, .Minute], fromDate: updatedDate)
        let todayComponents = NSCalendar.currentCalendar().components([.Month, .Day, .Year], fromDate: updatedDate)
        
        // Chacking if time is the same
        XCTAssertEqual(oldDateComponents.minute, newDateComponents.minute, "Minutes should be the same")
        XCTAssertEqual(oldDateComponents.hour, newDateComponents.hour, "Hours should be the same")
        
        // Chacking if date is updated
        XCTAssertEqual(newDateComponents.month, todayComponents.month, "Month should be the same")
        XCTAssertEqual(newDateComponents.day, todayComponents.day, "Day should be the same")
        XCTAssertEqual(newDateComponents.year, todayComponents.year, "Year should be the same")

    }
    
    func testUpdatedStartTime() {
        // Positive: case when manually started
        let manualStart = NSDate()
        testActivityTiming.manuallyStarted = manualStart
        XCTAssertEqual(testActivityTiming.updatedStartTime(), manualStart, "UpdatedStartTime should be equal to manually started")
        
        // Negative
        testActivityTiming.manuallyStarted = nil
        let upToDateStartTime = Timing.updateTimeForToday(testActivityTiming.startTime)
        XCTAssertEqual(testActivityTiming.updatedStartTime(), upToDateStartTime, "Updated start time should be regular start time")
    }
    
    func testUpdatedFinishTime() {
        // Positive: case when manually started
        let manualStart = NSDate()
        let manualFinish = manualStart.dateByAddingTimeInterval(testActivityTiming.duration.doubleValue * 60)
        testActivityTiming.manuallyStarted = manualStart
        XCTAssertEqual(testActivityTiming.updatedFinishTime(), manualFinish, "UpdatedStartTime should be equal to manually started")
        
        // Negative
        testActivityTiming.manuallyStarted = nil
        let upToDateFinishTime = Timing.updateTimeForToday(testActivityTiming.finishTime)
        XCTAssertEqual(testActivityTiming.updatedFinishTime(), upToDateFinishTime, "Updated finish time should be regular finish time")
        
        // start time now, finish time tomorrow -> ???
        let newStartTime = testCoreDataStack.shortStyleDateFormatter().dateFromString("7/3/15, 11:45 PM")!
        let newFinishTime = testCoreDataStack.shortStyleDateFormatter().dateFromString("7/4/15, 00:45 AM")!
        testActivityTiming.startTime = newStartTime
        testActivityTiming.finishTime = newFinishTime
        let timeInterval = testActivityTiming.updatedFinishTime().timeIntervalSinceDate(testActivityTiming.updatedStartTime())
        testActivityTiming.updateDuration()
        XCTAssertEqual(timeInterval, 60.0*60.0, "Time interval should be 3600 sec")
    }
    
    func testUpdatedAlarmTime() {
        let manualStart = NSDate()
        let newStartTime = testCoreDataStack.shortStyleDateFormatter().dateFromString("7/3/15, 11:05 AM")!
        let newFinishTime = testCoreDataStack.shortStyleDateFormatter().dateFromString("7/3/15, 11:45 AM")!
        testActivityTiming.startTime = newStartTime
        testActivityTiming.finishTime = newFinishTime
        testActivityTiming.duration = NSNumber(double: 40.0)
        testActivityTiming.timeToSave = NSNumber(double: 20.0)
        testActivityTiming.manuallyStarted = manualStart
        
        let alarmForRoutine = NSDate(timeInterval: 20.0 * 60.0, sinceDate: testActivityTiming.manuallyStarted!)
        XCTAssertEqual(testActivityTiming.updatedAlarmTime(), alarmForRoutine, "UpdatedAlarm time should be updated by manually started")
        
        // If it is a goal
        testActivityTiming.activity.type = Activity.typeWithEnum(.Goal)
        XCTAssertEqual(testActivityTiming.updatedAlarmTime(), testActivityTiming.updatedFinishTime(), "For goal alarm time is finishtime")
    }
    
    func testNextActionTime() {
        // is going now -> finishTime
        testActivityTiming.startTime = NSDate().dateByAddingTimeInterval(-60*60)
        testActivityTiming.finishTime = NSDate().dateByAddingTimeInterval(60*60)
        testActivityTiming.updateDuration()
        XCTAssertEqual(testActivityTiming.nextActionTime(), testActivityTiming.updatedFinishTime(), "Next action time should be finish time")
        
        // is passed due -> startTime tomorrow
        testActivityTiming.startTime = NSDate().dateByAddingTimeInterval(-60*60)
        testActivityTiming.finishTime = NSDate().dateByAddingTimeInterval(-20*60)
        testActivityTiming.updateDuration()

        let startTimeTomorrow = testActivityTiming.updatedStartTime().dateByAddingTimeInterval(60*60*24)
        XCTAssertEqual(testActivityTiming.nextActionTime(), startTimeTomorrow, "Next action time should be start time tomorrow")
        
        // is done for today -> startTime tomorrow
        testActivityTiming.finishTime = NSDate().dateByAddingTimeInterval(60*60)
        testActivityTiming.activity.finishWithResult()
        XCTAssertEqual(testActivityTiming.nextActionTime(), startTimeTomorrow, "Next action time should be start time tomorrow")
        
        // will be in future -> startTime
        deleteFakeResults()
        XCTAssertFalse(testActivityTiming.isDoneForToday(), "Activity should not be done for today")
        
        testActivityTiming.startTime = NSDate().dateByAddingTimeInterval(60*60)
        testActivityTiming.finishTime = NSDate().dateByAddingTimeInterval(80*60)
        XCTAssertEqual(testActivityTiming.nextActionTime(), testActivityTiming.updatedStartTime(), "Next action time should be start time today")

        // start time now, finish time tomorrow -> ???
        let newStartTime = testCoreDataStack.shortStyleDateFormatter().dateFromString("7/3/15, 00:45 AM")!
        let newFinishTime = testCoreDataStack.shortStyleDateFormatter().dateFromString("7/4/15, 00:45 AM")!
        testActivityTiming.startTime = newStartTime
        testActivityTiming.finishTime = newFinishTime
        testActivityTiming.updateDuration()
        XCTAssertEqual(testActivityTiming.nextActionTime(), testActivityTiming.updatedFinishTime(), "Next action time should be finish time")
        
    }
    
//    func testNextActionDateForWorkdaysFromFriday() {
//        testActivity.basis = Activity.basisWithEnum(.Workdays)
//        testActivity.finishWithResult()
//        
//        var correctNextActionDate: NSDate!
//        let dayName = LazyCalendar.correctWeekdayFromDate(NSDate())
//        if dayName == "Fri" {
//            correctNextActionDate = NSDate(timeInterval: 60*60*24*3, sinceDate: testActivity.updatedStartTime())
//        } else if dayName == "Sat" {
//            correctNextActionDate = NSDate(timeInterval: 60*60*24*2, sinceDate: testActivity.updatedStartTime())
//        } else {
//            correctNextActionDate = NSDate(timeInterval: 60*60*24, sinceDate: testActivity.updatedStartTime())
//        }
//
//        let nextActionDate = testActivity.timing!.nextActionDate()
//        XCTAssertEqual(nextActionDate, correctNextActionDate, "Next action date is wrong")
//    }
    
    func testNextActionDateWeekend() {
        testActivity.basis = Activity.basisWithEnum(.Weekends)
        testActivity.finishWithResult()
        
        let referenceDate = NSDate()
        var correctNextActionDate: NSDate!
        let dayName = LazyCalendar.correctWeekdayFromDate(NSDate())
        if dayName == "Sat" {
            correctNextActionDate = NSDate(timeInterval: 60*60*24, sinceDate: testActivity.updatedStartTime())
        } else if dayName == "Sun" {
            correctNextActionDate = NSDate(timeInterval: 60*60*24*6, sinceDate: testActivity.updatedStartTime())
        } else {
            correctNextActionDate = testActivity.timing!.nextWeekendDayFromDate(referenceDate)
        }
        let dateFormatter = DayResults.standardDateFormatter()
        let nextActionDate = dateFormatter.stringFromDate(testActivity.timing!.nextActionDate())
        let correctDate = dateFormatter.stringFromDate(correctNextActionDate)
        XCTAssertEqual(nextActionDate, correctDate, "Next action date is wrong")
    }
    
    func testNextWeekendDateFromDate() {
        let startDate = testCoreDataStack.shortStyleDateFormatter().dateFromString("7/7/15, 10:15 AM")
        _ = LazyCalendar.correctWeekdayFromDate(startDate!)
        
        let nextSaturday = testActivity.timing!.nextWeekendDayFromDate(startDate!)
        let correctNextSaturday = NSDate(timeInterval: 60*60*24*4, sinceDate: startDate!)
        XCTAssertEqual(nextSaturday, correctNextSaturday, "Next saturday date is wrong")
    }
    
    //MARK: - Helper functions
    
    func deleteFakeResults() {
        if let result = DayResults.fetchResultWithDate(NSDate(), forActivity: testActivityTiming.activity) {
            testActivityTiming.managedObjectContext?.deleteObject(result)
        }
    }

    

}
