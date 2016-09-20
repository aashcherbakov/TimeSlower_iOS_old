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

class TimingManageTest: CoreDataBaseTest {

    var standartDateFormatter: DateFormatter!
    var timeMachine: TimeMachine!
    
    var shortDateFormatter: DateFormatter!
    
    override func setUp() {
        super.setUp()
        
        shortDateFormatter = StaticDateFormatter.shortDateAndTimeFormatter
        timeMachine = TimeMachine()
    }
    
    override func tearDown() {
        testCoreDataStack.managedObjectContext!.delete(testProfile)
        testCoreDataStack.managedObjectContext!.delete(testActivity)
        testCoreDataStack.managedObjectContext!.delete(testActivityStats)
        testCoreDataStack.managedObjectContext!.delete(testActivityTiming)
        
        testCoreDataStack = nil
        super.tearDown()
    }
    
    func testCreation() {
        XCTAssertNotNil(testActivityTiming, "Timing should not be nil")
        XCTAssertTrue(testActivityTiming.responds(to: #selector(Activity.updatedStartTime)), "Timing class")
        XCTAssertTrue(testActivityTiming.activity.responds(to: #selector(Activity.isRoutine)), "Timing should have activity attached")
        
        let startTime = testCoreDataStack.shortStyleDateFormatter().date(from: "7/3/15, 10:15 AM")!
        let finishTime = testCoreDataStack.shortStyleDateFormatter().date(from: "7/3/15, 10:45 AM")!
        XCTAssertEqual(testActivityTiming.startTime, startTime, "Start time has to be 10:15")
        XCTAssertEqual(testActivityTiming.finishTime, finishTime, "Finish time has to be 10:45")
        XCTAssertEqual(testActivityTiming.timeToSave, NSNumber(value: 10.0 as Double), "Time to save has to be 10 min")
    }
    
    func testIsPassedDueForToday() {
        // Positive
        testActivityTiming.finishTime = Date().addingTimeInterval(-60*60)
        XCTAssertTrue(testActivityTiming.isPassedDueForToday(), "Avtivity should be passed due")
        
        // Negative
        testActivityTiming.finishTime = Date().addingTimeInterval(60*60)
        XCTAssertFalse(testActivityTiming.isPassedDueForToday(), "Avtivity should not be passed due")
    }
    
    func testFinishTimeIsNextDay() {
        let newStartTime = testCoreDataStack.shortStyleDateFormatter().date(from: "7/3/15, 11:45 PM")!
        let newFinishTime = testCoreDataStack.shortStyleDateFormatter().date(from: "7/4/15, 00:45 AM")!
        testActivityTiming.startTime = newStartTime
        testActivityTiming.finishTime = newFinishTime
        XCTAssertTrue(testActivityTiming.finishTimeIsNextDay(), "Finish time must be next day")
    }
    
    func testIsGoingNow() {
        // Positive
        testActivityTiming.startTime = Date().addingTimeInterval(-60*60)
        testActivityTiming.finishTime = Date().addingTimeInterval(60*60)
        XCTAssertTrue(testActivityTiming.isGoingNow(), "Activity should be going now")
        
        // Negative
        testActivityTiming.startTime = Date().addingTimeInterval(-60*60)
        testActivityTiming.finishTime = Date().addingTimeInterval(-20*60)
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
        let twoDaysAgoDate = Date().addingTimeInterval(-60*60*24*2)
        let updatedDate = Timing.updateTimeForToday(twoDaysAgoDate)
        
        let oldDateComponents = (Calendar.current as NSCalendar).components([.hour, .minute], from: twoDaysAgoDate)
        let newDateComponents = (Calendar.current as NSCalendar).components([.month, .day, .year, .hour, .minute], from: updatedDate)
        let todayComponents = (Calendar.current as NSCalendar).components([.month, .day, .year], from: updatedDate)
        
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
        let manualStart = Date()
        testActivityTiming.manuallyStarted = manualStart
        XCTAssertEqual(testActivityTiming.updatedStartTime(), manualStart, "UpdatedStartTime should be equal to manually started")
        
        // Negative
        testActivityTiming.manuallyStarted = nil
        let upToDateStartTime = Timing.updateTimeForToday(testActivityTiming.startTime)
        XCTAssertEqual(testActivityTiming.updatedStartTime(), upToDateStartTime, "Updated start time should be regular start time")
    }
    
    func test_updatedStartTimeForDate() {
        // given
        let time = shortDateFormatter.date(from: "8/23/16, 10:00 AM")!
        let newDate = shortDateFormatter.date(from: "3/28/17, 12:00 PM")!
        let expectedDate = shortDateFormatter.date(from: "3/28/17, 10:00 AM")!
        
        // when
        testActivityTiming.manuallyStarted = nil
        testActivityTiming.startTime = time
        let result = testActivityTiming.updatedStartTimeForDate(newDate)
        
        // then
        XCTAssertEqual(result, expectedDate, "it should give updated date")
    }
    
    func testUpdatedFinishTime() {
        // Positive: case when manually started
        let manualStart = Date()
        let manualFinish = manualStart.addingTimeInterval(Double(testActivityTiming.duration.value) * 60)
        testActivityTiming.manuallyStarted = manualStart
        XCTAssertEqual(testActivityTiming.updatedFinishTime(), manualFinish, "UpdatedStartTime should be equal to manually started")
        
        // Negative
        testActivityTiming.manuallyStarted = nil
        let upToDateFinishTime = Timing.updateTimeForToday(testActivityTiming.finishTime)
        XCTAssertEqual(testActivityTiming.updatedFinishTime(), upToDateFinishTime, "Updated finish time should be regular finish time")
        
        // start time now, finish time tomorrow -> ???
        let newStartTime = testCoreDataStack.shortStyleDateFormatter().date(from: "7/3/15, 11:45 PM")!
        let newFinishTime = testCoreDataStack.shortStyleDateFormatter().date(from: "7/4/15, 00:45 AM")!
        testActivityTiming.startTime = newStartTime
        testActivityTiming.finishTime = newFinishTime
        let timeInterval = testActivityTiming.updatedFinishTime().timeIntervalSince(testActivityTiming.updatedStartTime())
        XCTAssertEqual(timeInterval, 60.0*60.0, "Time interval should be 3600 sec")
    }
    
    func testUpdatedAlarmTime() {
        let manualStart = Date()
        let newStartTime = testCoreDataStack.shortStyleDateFormatter().date(from: "7/3/15, 11:05 AM")!
        let newFinishTime = testCoreDataStack.shortStyleDateFormatter().date(from: "7/3/15, 11:45 AM")!
        testActivityTiming.startTime = newStartTime
        testActivityTiming.finishTime = newFinishTime
        testActivityTiming.duration = ActivityDuration(value: 40, period: .minutes)
        testActivityTiming.timeToSave = NSNumber(value: 20.0 as Double)
        testActivityTiming.manuallyStarted = manualStart
        
        let alarmForRoutine = Date(timeInterval: 20.0 * 60.0, since: testActivityTiming.manuallyStarted!)
        XCTAssertEqual(testActivityTiming.updatedAlarmTime(), alarmForRoutine, "UpdatedAlarm time should be updated by manually started")
        
        // If it is a goal
        testActivityTiming.activity.type = Activity.typeWithEnum(.goal)
        XCTAssertEqual(testActivityTiming.updatedAlarmTime(), testActivityTiming.updatedFinishTime(), "For goal alarm time is finishtime")
    }
    
    // MARK: - Next Action Time
    
    func test_nextActionTime() {
        // is going now -> finishTime
        testActivityTiming.startTime = Date().addingTimeInterval(-60*60)
        testActivityTiming.finishTime = Date().addingTimeInterval(60*60)
        XCTAssertEqual(testActivityTiming.nextActionTime(), testActivityTiming.updatedFinishTime(), "Next action time should be finish time")
        
        // is passed due -> startTime tomorrow
        testActivityTiming.startTime = Date().addingTimeInterval(-60*60)
        testActivityTiming.finishTime = Date().addingTimeInterval(-20*60)

        let startTimeTomorrow = testActivityTiming.updatedStartTime().addingTimeInterval(60*60*24)
        XCTAssertEqual(testActivityTiming.nextActionTime(), startTimeTomorrow, "Next action time should be start time tomorrow")
        
        // is done for today -> startTime tomorrow
        testActivityTiming.finishTime = Date().addingTimeInterval(60*60)
        testActivityTiming.activity.finishWithResult()
        XCTAssertEqual(testActivityTiming.nextActionTime(), startTimeTomorrow, "Next action time should be start time tomorrow")
        
        // will be in future -> startTime
        deleteFakeResults()
        XCTAssertFalse(testActivityTiming.isDoneForToday(), "Activity should not be done for today")
        
        testActivityTiming.startTime = Date().addingTimeInterval(60*60)
        testActivityTiming.finishTime = Date().addingTimeInterval(80*60)
        XCTAssertEqual(testActivityTiming.nextActionTime(), testActivityTiming.updatedStartTime(), "Next action time should be start time today")

        // start time now, finish time tomorrow -> ???
        let newStartTime = testCoreDataStack.shortStyleDateFormatter().date(from: "7/3/15, 00:45 AM")!
        let newFinishTime = testCoreDataStack.shortStyleDateFormatter().date(from: "7/4/15, 00:45 AM")!
        testActivityTiming.startTime = newStartTime
        testActivityTiming.finishTime = newFinishTime
        XCTAssertEqual(testActivityTiming.nextActionTime(), testActivityTiming.updatedFinishTime(), "Next action time should be finish time")
        
    }
    
//    func testNextActionDateForWorkdaysFromFriday() {
//        testActivity.basis = Activity.basisWithEnum(.Workdays)
//        testActivity.finishWithResult()
//        
//        var correctNextActionDate: NSDate!
//        let dayName = timeMachine.correctWeekdayFromDate(NSDate())
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
        testActivity.basis = Activity.basisWithEnum(.weekends)
        testActivity.finishWithResult()
        
        let referenceDate = Date()
        var correctNextActionDate: Date!
        let dayName = Weekday.shortDayNameForDate(referenceDate)
        if dayName == "Sat" {
            correctNextActionDate = Date(timeInterval: 60*60*24, since: testActivity.updatedStartTime())
        } else if dayName == "Sun" {
            correctNextActionDate = Date(timeInterval: 60*60*24*6, since: testActivity.updatedStartTime())
        } else {
//            correctNextActionDate = testActivity.timing.nextWeekendDayFromDate(referenceDate)
        }
        let dateFormatter = DayResults.standardDateFormatter()
        let nextActionDate = dateFormatter.string(from: testActivity.timing.nextActionDate())
//        let correctDate = dateFormatter.string(from: correctNextActionDate)
//        XCTAssertEqual(nextActionDate, correctDate, "Next action date is wrong")
    }
    
    func testNextWeekendDateFromDate() {
        let startDate = testCoreDataStack.shortStyleDateFormatter().date(from: "7/7/15, 10:15 AM")
        _ = Weekday.shortDayNameForDate(startDate!)
        
//        let nextSaturday = testActivity.timing.nextWeekendDayFromDate(startDate!)
        let correctNextSaturday = Date(timeInterval: 60*60*24*4, since: startDate!)
//        XCTAssertEqual(nextSaturday, correctNextSaturday, "Next saturday date is wrong")
    }
    
    func test_activityStartTimeInDate() {
        let startDate = StaticDateFormatter.shortDateAndTimeFormatter.date(from: "7/7/15, 10:15 AM")!
        let nextActionDate = StaticDateFormatter.shortDateAndTimeFormatter.date(from: "9/8/16, 00:00 AM")!
        let expectedDate = StaticDateFormatter.shortDateAndTimeFormatter.date(from: "9/8/16, 10:15 AM")!
        XCTAssertEqual(testActivity.timing.activityStartTime(startDate, inDate: nextActionDate), expectedDate, "it should be 10:15 on August 9th 2016")
    }
    
    //MARK: - Helper functions
    
    func deleteFakeResults() {
        if let result = DayResults.fetchResultWithDate(Date(), forActivity: testActivityTiming.activity) {
            testActivityTiming.managedObjectContext?.delete(result)
        }
    }

    

}
