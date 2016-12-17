//
//  ResultAdapterTests.swift
//  TimeSlowerKit
//
//  Created by Alexander Shcherbakov on 9/10/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import XCTest
@testable import TimeSlowerDataBase
@testable import TimeSlowerKit

class ResultAdapterTests: BaseDataStoreTest {
    
    var sut: ResultAdapter!

    override func setUp() {
        super.setUp()
        sut = ResultAdapter(withCoreDataStack: fakeCoreDataStack)
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func test_creatingResult() {
        let activity = fakeActivity()
        ActivityAdapter(withCoreDataStack: fakeCoreDataStack).createObject(activity)
        
        let result = Result(withActivity: activity)
        let savedResult: Result = sut.createObject(result, parent: activity)
        
        XCTAssertEqual(savedResult.activity.name, activity.name)
    }

    
    // MARK: - Helper functions
    
    func tenThirtyAM() -> Date {
        return shortTimeFormatter.date(from: "8/10/2016, 10:30 AM")!
    }
    
    func elevenTenAM() -> Date {
        return shortTimeFormatter.date(from: "8/10/2016, 11:10 AM")!
    }
    
    func fakeActivity() -> Activity {
        return Activity(
            withLifetimeDays: 18105,
            name: "Morning shower",
            type: .routine,
            days: [.first, .second, .third],
            timing: fakeTiming(),
            notifications: false)
    }
    
    func fakeTiming() -> Timing {
        return Timing(
            withDuration: fakeEndurance(),
            startTime: tenThirtyAM(),
            timeToSave: 10,
            alarmTime: NSDate() as Date,
            manuallyStarted: nil)
    }
    
    func fakeEndurance() -> Endurance {
        return Endurance(value: 30, period: .minutes)
    }
    
    func fakeStats() -> Estimates {
        return Estimates(hours: 0, days: 0, months: 0, years: 0)
    }
    
}
