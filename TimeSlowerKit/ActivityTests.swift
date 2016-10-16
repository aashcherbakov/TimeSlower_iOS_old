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
    
    override func setUp() {
        super.setUp()
        sut = FakeActivityFactory().fakeActivity()
        dataStore = DataStore(withCoreDataStack: fakeCoreDataStack)
        dataStore.create(sut)
    }
    
    override func tearDown() {
        sut = nil
        dataStore = nil
        super.tearDown()
    }

    func test_startsLaterThenDate() {
        let date = shortTimeFormatter.date(from: "10/18/2016, 10:00 AM")!
        XCTAssertTrue(sut.startsLaterThen(date: date))
    }
    
    func test_startsLaterThenDate_false() {
        let date = shortTimeFormatter.date(from: "10/18/2016, 12:00 PM")!
        XCTAssertFalse(sut.startsLaterThen(date: date))
    }
    
    func test_startEarlierThenActivity_false() {
        let earlyDate = shortTimeFormatter.date(from: "10/15/2016, 8:00 AM")!
        let earlyActivity = FakeActivityFactory().fakeActivity(startTime: earlyDate)
        XCTAssertFalse(sut.startsEarlierThen(activity: earlyActivity))
    }
    
    func test_startEarlierThenActivity_true() {
        let laterDate = shortTimeFormatter.date(from: "10/20/2016, 10:31 AM")!
        let laterActivity = FakeActivityFactory().fakeActivity(startTime: laterDate)
        XCTAssertTrue(sut.startsEarlierThen(activity: laterActivity))
    }
    
    func test_isDoneForToday() {
        let date = shortTimeFormatter.date(from: "10/18/2016, 10:00 AM")!
        XCTAssertFalse(sut.isDone(forDate: date))
    }
    
    func test_isDoneForToday_success() {
        let date = shortTimeFormatter.date(from: "10/18/2016, 10:00 AM")!
        let result = Result(withActivity: sut, factFinish: date)
        
        dataStore.create(result, withParent: sut)
        sut = dataStore.retrieve(sut.resourceId)
        let isDone = sut.isDone(forDate: date)
        XCTAssertTrue(isDone)
    }
    
    func test_nextActionDay_monday() {
        let friday = shortTimeFormatter.date(from: "10/14/2016, 10:00 AM")!
        let monday = shortTimeFormatter.date(from: "10/16/2016, 10:00 AM")!
        XCTAssertEqual(sut.nextActionDay(fromDate: friday), monday)
    }
    
    func test_nextActionDay_inAWeek() {
        let wednesday = shortTimeFormatter.date(from: "10/12/2016, 10:00 AM")!
        let monday = shortTimeFormatter.date(from: "10/16/2016, 10:00 AM")!
        XCTAssertEqual(sut.nextActionDay(fromDate: wednesday), monday)
    }
    
    func test_nextActionDay_nextDay() {
        let monday = shortTimeFormatter.date(from: "10/10/2016, 10:00 AM")!
        let tuesday = shortTimeFormatter.date(from: "10/11/2016, 10:00 AM")!
        XCTAssertEqual(sut.nextActionDay(fromDate: monday), tuesday)
    }
    
    func test_alarmTime() {
        let tuesday = shortTimeFormatter.date(from: "10/11/2016, 10:00 AM")!
        let alarmTime = shortTimeFormatter.date(from: "10/11/2016, 10:30 AM")!
        let timing = sut.updateTiming(withManuallyStarted: tuesday)
        let startedActivity = sut.update(withTiming: timing)
        sut = startedActivity
        XCTAssertEqual(sut.alarmTime(inDate: tuesday), alarmTime)
    }
}
