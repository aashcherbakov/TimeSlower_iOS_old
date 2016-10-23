//
//  ActivitySchedulerTests.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 10/12/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import XCTest
import TimeSlowerKit
import TimeSlowerDataBase

class ActivitySchedulerTests: BaseDataStoreTest {
    
    var sut: ActivityScheduler!
    var fakeDataStore: DataStore!
    var factory: FakeActivityFactory!
    var wednesday: Date!
    var tuesday: Date!
    
    override func setUp() {
        super.setUp()
        let fakeCoreDataStack = FakeCoreDataStack()
        fakeDataStore = DataStore(withCoreDataStack: fakeCoreDataStack)
        factory = FakeActivityFactory()
        sut = ActivityScheduler(withDataStore: fakeDataStore)
        wednesday = shortDateFormatter.date(from: "10/12/2016")!
        tuesday = shortDateFormatter.date(from: "10/11/2016")!
    }
    
    override func tearDown() {
        sut = nil
        fakeCoreDataStack = nil
        factory = nil
        wednesday = nil
        tuesday = nil
        super.tearDown()
    }
    
    func test_activitiesForToday_empty() {
        let wednesday = shortDateFormatter.date(from: "10/12/2016")!
        let activities = sut.activitiesForDate(date: wednesday)
        XCTAssertEqual(activities.count, 0)
    }
    
    func test_activitiesForToday_emptyDay() {
        let wednesday = shortDateFormatter.date(from: "10/12/2016")!
        let activity = FakeActivityFactory().fakeActivity()
        fakeDataStore.create(activity)
        
        let activities = sut.activitiesForDate(date: wednesday)
        XCTAssertEqual(activities.count, 0)
    }
    
    func test_activitiesForToday_oneOnTuesday() {
        let tuesday = shortDateFormatter.date(from: "10/11/2016")!
        let activityDaily = factory.fakeActivity(days: [.third])
        fakeDataStore.create(activityDaily)
        let activityWeekends = factory.fakeActivity(days: [.forth])
        fakeDataStore.create(activityWeekends)
        
        let activities = sut.activitiesForDate(date: tuesday)
        XCTAssertEqual(activities.count, 1)
    }
    

    func test_nextClosestActivity() {
        let ten = shortTimeFormatter.date(from: "10/11/2016, 10:00 AM")!
        let tenThirty = shortTimeFormatter.date(from: "10/11/2016, 10:30 AM")!
        
        let activity = factory.fakeActivity(startTime: tenThirty)
        fakeDataStore.create(activity)
        
        let nextClosestActivity = sut.nextClosestActivity(forDate: ten)
        XCTAssertNotNil(nextClosestActivity)
        XCTAssertEqual(nextClosestActivity?.name, activity.name)
        XCTAssertEqual(nextClosestActivity?.startTime(inDate: tenThirty), activity.startTime(inDate: tenThirty))
    }
    
    func test_currentActivity() {
        let tenFifteen = shortTimeFormatter.date(from: "10/18/2016, 10:45 AM")!
        let activity = factory.fakeActivity()
        fakeDataStore.create(activity)
        
        let current = sut.currentActivity(date: tenFifteen)
        XCTAssertNotNil(current)
        XCTAssertEqual(current?.name, activity.name)
        XCTAssertEqual(current?.startTime(inDate: tenFifteen), activity.startTime(inDate: tenFifteen))
    }
    
    func test_currentActivity_none() {
        let tenFifteen = shortTimeFormatter.date(from: "10/18/2016, 10:29 AM")!
        let activity = factory.fakeActivity()
        fakeDataStore.create(activity)
        
        let current = sut.currentActivity(date: tenFifteen)
        XCTAssertNil(current)
    }
    
    func test_startActivity() {
        let tenThirty = shortTimeFormatter.date(from: "10/18/2016, 10:30 AM")!
        let activity = factory.fakeActivity()
        let createdActivity = fakeDataStore.create(activity)

        let startedActivity = sut.start(activity: createdActivity, time: tenThirty)
        XCTAssertEqual(startedActivity.getTiming().manuallyStarted, tenThirty)
        
        let currentActivity = sut.currentActivity(date: tenThirty)
        XCTAssertEqual(startedActivity.resourceId, currentActivity?.resourceId)        
    }
    
    func test_finishActivity() {
        
    }
}
