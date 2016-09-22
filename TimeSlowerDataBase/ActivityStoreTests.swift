//
//  ActivityStoreTests.swift
//  TimeSlowerKit
//
//  Created by Oleksandr Shcherbakov on 9/3/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import XCTest
import TimeSlowerDataBase

class ActivityStoreTests: BaseDataStoreTest {

    var sut: ActivityStore!
    
    override func setUp() {
        super.setUp()
        sut = ActivityStore(withCoreDataStack: fakeCoreDataStack)
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func test_createEntity_withDefaultParameters() {
        let activity: ActivityEntity = sut.createEntity()
        
        XCTAssertEqual(activity.name, "No name")
        XCTAssertEqual(activity.days, [])
        XCTAssertEqual(activity.averageSuccess, 0)
        XCTAssertEqual(activity.notifications, false)
        XCTAssertEqual(activity.timing.duration.value, 0)
        XCTAssertEqual(activity.stats.summDays, 0)
        XCTAssertNil(activity.results)
    }
    
    func test_createEntity() {
        let startTime = shortTimeFormatter.date(from: "9/1/16, 10:30 AM")!
        let finishTime = shortTimeFormatter.date(from: "9/1/16, 11:00 AM")!
        
        let activity = fakeActivity()
        
        XCTAssertNotNil(activity)
        XCTAssertEqual(activity.name, "Shower")
        XCTAssertEqual(activity.days, [Day(number: 1), Day(number: 2)])
        XCTAssertEqual(activity.timing.startTime, startTime)
        XCTAssertEqual(activity.timing.finishTime, finishTime)
        XCTAssertEqual(activity.averageSuccess, 0)
    }

    func test_entityForKey() {
        let shower = fakeActivity()
        
        let foundActivity: ActivityEntity = sut.entityForKey(shower.resourceId)!
       
        XCTAssertNotNil(foundActivity)
        XCTAssertEqual(foundActivity.name, "Shower")
        XCTAssertEqual(foundActivity.days, [Day(number: 1), Day(number: 2)])
        XCTAssertEqual(foundActivity.averageSuccess, 0)
        XCTAssertEqual(foundActivity.notifications, false)
    }
    
    func test_updateEntity() {
        let startTime = shortTimeFormatter.date(from: "9/1/16, 10:30 AM")!
        let finishTime = shortTimeFormatter.date(from: "9/1/16, 11:10 AM")!


        let updatedEntity: ActivityEntity = sut.updateEntity(fakeActivity(), configuration: updateConfiguration())
        
        XCTAssertEqual(updatedEntity.name, "Shower", "it should not change name")
        XCTAssertEqual(updatedEntity.days, [Day(number: 0), Day(number: 6)])
        XCTAssertEqual(updatedEntity.averageSuccess, 80)
        XCTAssertEqual(updatedEntity.notifications, true)
        XCTAssertEqual(updatedEntity.timing.startTime, startTime)
        XCTAssertEqual(updatedEntity.timing.finishTime, finishTime)
        XCTAssertEqual(updatedEntity.timing.duration.value, 40)
        XCTAssertEqual(updatedEntity.timing.alarmTime, startTime)
        XCTAssertEqual(updatedEntity.stats.summDays, 5)
    }
    
    func test_deleteEntity() {
        // given
        let activityToDelete = fakeActivity()
        let foundAfterCreation: ActivityEntity = sut.entityForKey(activityToDelete.resourceId)!
        XCTAssertNotNil(foundAfterCreation)
        
        // when
        sut.deleteEntity(activityToDelete)
        let foundAfterDeletion: ActivityEntity? = sut.entityForKey(activityToDelete.resourceId)
        
        // then
        XCTAssertNil(foundAfterDeletion)
    }
    
    func test_allActivities() {
        let _ = fakeActivity()
        let activities = sut.allActivities()
        XCTAssertEqual(activities.count, 1)
    }
    
    func test_activitiesForDate() {
        // given
        let actvityForMondayAndTuesday = fakeActivity()
        let monday = shortDateFormatter.date(from: "9/19/2016")!
        
        // when
        let activities = sut.activities(forDate: monday, ofType: .routine)
        
        // then
        XCTAssertEqual(activities.count, 1)
        XCTAssertEqual(activities.first, actvityForMondayAndTuesday)
    }
    
    func test_activitiesForDate_False() {
        // given
        let _ = fakeActivity()
        let sunday = shortDateFormatter.date(from: "9/18/2016")!
        
        // when
        let activities = sut.activities(forDate: sunday,  ofType: .routine)
        
        // then
        XCTAssertEqual(activities.count, 0)
    }
    
    
    // MARK: - Helpers
    
    func fakeActivity() -> ActivityEntity {
        let startTime = shortTimeFormatter.date(from: "9/1/16, 10:30 AM")!
        let duration = Continuation(value: 30, period: .minutes)
        
        let timing = TimingData(duration: duration, alarmTime: Date(), startTime: startTime, timeToSave: 10)
        let stats = StatsData(days: 0, hours: 0, months: 0, years: 0)
        
        let configuration = ActivityConfiguration(
            name: "Shower",
            type: 0,
            days: [1,2],
            timing: timing,
            stats: stats,
            notifications: false,
            averageSuccess: 0, resourceId: "333333")
        
        let activity: ActivityEntity = sut.createEntity()
        let activityWithData: ActivityEntity = sut.updateEntity(activity, configuration: configuration)
        return activityWithData
    }
    
    func updateConfiguration() -> ActivityConfiguration {
        let startTime = shortTimeFormatter.date(from: "9/1/16, 10:30 AM")!
        let duration = Continuation(value: 40, period: .minutes)
        let timing = TimingData(duration: duration, alarmTime: startTime, startTime: startTime, timeToSave: 20)
        let stats = StatsData(days: 5, hours: 5, months: 5, years: 5)
        

        return ActivityConfiguration(
            name: "Shower",
            type: 1,
            days: [0, 6],
            timing: timing,
            stats: stats,
            notifications: true,
            averageSuccess: 80,
            resourceId: "333333")
    }
}
