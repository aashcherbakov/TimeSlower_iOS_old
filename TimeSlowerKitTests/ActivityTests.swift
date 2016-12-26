//
//  ActivityTests.swift
//  TimeSlowerKit
//
//  Created by Oleksandr Shcherbakov on 9/3/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import XCTest
@testable import TimeSlowerKit

class ActivityTests: BaseDataStoreTest {

    var sut: Activity!
    var dataStore: DataStore!
    var factory: FakeActivityFactory!

    override func setUp() {
        super.setUp()
        factory = FakeActivityFactory()
        let fakeActivity = factory.fakeActivity()
        dataStore = DataStore(withCoreDataStack: fakeCoreDataStack)
        sut = dataStore.create(fakeActivity)
    }
    
    override func tearDown() {
        sut = nil
        dataStore = nil
        super.tearDown()
    }

    // MARK: - Comparing dates

    func test_startsLaterThenDate() {
        let date = shortTimeFormatter.date(from: "10/18/2016, 10:00 AM")!
        XCTAssertTrue(sut.startsLater(then: date))
    }
    
    func test_startsLaterThenDate_false() {
        let date = shortTimeFormatter.date(from: "10/18/2016, 12:00 PM")!
        XCTAssertFalse(sut.startsLater(then: date))
    }
    
    func test_startEarlierThenActivity_false() {
        let earlyDate = shortTimeFormatter.date(from: "10/15/2016, 8:00 AM")!
        let earlyActivity = factory.fakeActivity(startTime: earlyDate)
        XCTAssertFalse(sut.startsEarlier(then: earlyActivity))
    }
    
    func test_startEarlierThenActivity_true() {
        let laterDate = shortTimeFormatter.date(from: "10/20/2016, 10:31 AM")!
        let laterActivity = factory.fakeActivity(startTime: laterDate)
        XCTAssertTrue(sut.startsEarlier(then: laterActivity))
    }
    
    // MARK: - happensIn(date) {
    
    func test_happensIn_success() {
        let controlDate = shortTimeFormatter.date(from: "10/11/2016, 00:05 AM")!
        XCTAssertTrue(sut.happensIn(date: controlDate))
    }
    
    func test_happensIn_false() {
        let controlDate = shortTimeFormatter.date(from: "10/12/2016, 00:05 AM")!
        XCTAssertFalse(sut.happensIn(date: controlDate))
    }
    
    // MARK: - isDone()
    
    func test_isDoneForToday_negative() {
        let date = shortTimeFormatter.date(from: "10/18/2016, 10:00 AM")!
        XCTAssertFalse(sut.isDone(forDate: date))
    }
    
    func test_isDoneForToday_success() {
        let date = shortTimeFormatter.date(from: "10/18/2016, 10:00 AM")!
        let result = Result(withActivity: sut, factFinish: date)
        
        let _ = dataStore.create(result, withParent: sut)
        sut = dataStore.retrieve(sut.resourceId)
        let isDone = sut.isDone(forDate: date)
        XCTAssertTrue(isDone)
    }
    
    // MARK: - isGoingNow() 
    
    func test_isGoingNow_true() {
        let elevenOcklock = shortTimeFormatter.date(from: "10/11/2016, 11:00 AM")!
        let isGoingNow = sut.isGoingNow(date: elevenOcklock)
        XCTAssertTrue(isGoingNow)
    }
    
    func test_isGoingNow_evening() {
        let elevenOcklock = shortTimeFormatter.date(from: "10/11/2016, 11:00 PM")!
        let tenForty = shortTimeFormatter.date(from: "10/11/2016, 10:40 PM")!
        
        let timing = Timing(withDuration: FakeActivityFactory.fakeEndurance(), startTime: tenForty, timeToSave: 15, alarmTime: tenForty)
        sut.update(with: timing)
        let isGoingNow = sut.isGoingNow(date: elevenOcklock)
        XCTAssertTrue(isGoingNow)
    }
    
    func test_isGoingNow_manuallyStarted_true() {
        let eightOcklock = shortTimeFormatter.date(from: "10/11/2016, 8:00 AM")!
        let eightTwanty = shortTimeFormatter.date(from: "10/11/2016, 8:20 AM")!
        let timing = Timing(withDuration: FakeActivityFactory.fakeEndurance(), startTime: sut.startTime(), timeToSave: 15, alarmTime: sut.startTime(), manuallyStarted: eightOcklock)
        sut.update(with: timing)
        let isGoingNow = sut.isGoingNow(date: eightTwanty)
        XCTAssertTrue(isGoingNow)
    }
    
    // MARK: - isUnfinished()
    
    func test_isUnfinished_true_edgeCase() {
        let started = shortTimeFormatter.date(from: "10/11/2016, 11:45 PM")!
        let controlDate = shortTimeFormatter.date(from: "10/12/2016, 00:45 AM")!
        sut.setManuallyStarted(to: started)
        XCTAssertTrue(sut.isUnfinished(forDate: controlDate))
    }
    
    func test_isUnfinished_true_simple() {
        let started = shortTimeFormatter.date(from: "10/11/2016, 11:45 AM")!
        let controlDate = shortTimeFormatter.date(from: "11/11/2016, 12:45 PM")!
        sut.setManuallyStarted(to: started)
        XCTAssertTrue(sut.isUnfinished(forDate: controlDate))
    }
    
    func test_isUnfinished_false_finishTime() {
        let started = shortTimeFormatter.date(from: "10/11/2016, 11:45 PM")!
        let controlDate = shortTimeFormatter.date(from: "10/12/2016, 00:05 AM")!
        sut.setManuallyStarted(to: started)
        XCTAssertFalse(sut.isUnfinished(forDate: controlDate))
    }
    
    func test_isUnfinished_false_notStarted() {
        let controlDate = shortTimeFormatter.date(from: "11/11/2016, 12:45 PM")!
        sut.setManuallyStarted(to: nil)
        XCTAssertFalse(sut.isUnfinished(forDate: controlDate))
    }
    
    // MARK: - nextActionTime()
    
    func test_nextActionTime_today() {
        let controlDate = shortTimeFormatter.date(from: "10/11/2016, 10:25 AM")!
        let expectedDate = shortTimeFormatter.date(from: "10/11/2016, 10:30 AM")!
        let result = sut.nextActionTime(forDate: controlDate)
        XCTAssertEqual(expectedDate, result)
    }
    
    func test_nextActionTime_isGoingNow() {
        let controlDate = shortTimeFormatter.date(from: "10/11/2016, 10:45 AM")!
        let expectedDate = shortTimeFormatter.date(from: "10/11/2016, 11:10 AM")!
        let result = sut.nextActionTime(forDate: controlDate)
        XCTAssertEqual(expectedDate, result)
    }
    
    func test_nextActionTime_nextDay() {
        let controlDate = shortTimeFormatter.date(from: "10/14/2016, 11:50 AM")!
        let expectedDate = shortTimeFormatter.date(from: "10/16/2016, 10:30 AM")!
        let result = sut.nextActionTime(forDate: controlDate)
        XCTAssertEqual(expectedDate, result)
    }
    
    // if isDone
    // if isGoingNow
    // next start time

    // MARK: - nextActionDay()
    
    func test_nextActionDay_monday() {
        let friday = shortTimeFormatter.date(from: "10/14/2016, 10:00 AM")!
        let monday = shortTimeFormatter.date(from: "10/16/2016, 10:30 AM")!
        XCTAssertEqual(sut.nextActionTime(forDate: friday), monday)
    }
    
    func test_nextActionDay_inAWeek() {
        let wednesday = shortTimeFormatter.date(from: "10/12/2016, 10:00 AM")!
        let monday = shortTimeFormatter.date(from: "10/16/2016, 10:30 AM")!
        XCTAssertEqual(sut.nextActionTime(forDate: wednesday), monday)
    }
    
    func test_nextActionDay_nextDay() {
        let monday = shortTimeFormatter.date(from: "10/10/2016, 11:50 AM")!
        let tuesday = shortTimeFormatter.date(from: "10/11/2016, 10:30 AM")!
        XCTAssertEqual(sut.nextActionTime(forDate: monday), tuesday)
    }
    
    func test_alarmTime() {
        let tuesday = shortTimeFormatter.date(from: "10/11/2016, 10:00 AM")!
        let alarmTime = shortTimeFormatter.date(from: "10/11/2016, 10:30 AM")!
        sut.setManuallyStarted(to: tuesday)
        XCTAssertEqual(sut.alarmTime(inDate: tuesday), alarmTime)
        XCTAssertEqual(sut.getTiming().manuallyStarted, tuesday)
    }
    
    func test_startsEarlierThenDate() {
        let elevenOcklock = shortTimeFormatter.date(from: "10/11/2016, 11:00 AM")!
        let startsEarlier = sut.startsEarlier(then: elevenOcklock)
        XCTAssertTrue(startsEarlier)
    }
    
    
    func test_basis() {
        XCTAssertEqual(sut.basis(), Basis.random)
    }

}
