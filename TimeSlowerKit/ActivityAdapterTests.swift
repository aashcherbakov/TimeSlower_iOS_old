//
//  ActivityAdapterTests.swift
//  TimeSlowerKit
//
//  Created by Oleksandr Shcherbakov on 9/4/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import XCTest
@testable import TimeSlowerKit
@testable import TimeSlowerDataBase

class ActivityAdapterTests: BaseDataStoreTest {

    var sut: ActivityAdapter!
    var fakeActivity: Activity!
    
    override func setUp() {
        super.setUp()
        sut = ActivityAdapter(withCoreDataStack: fakeCoreDataStack)
        fakeActivity = TestHelper().fakeActivity()
    }
    
    override func tearDown() {
        sut = nil
        fakeActivity = nil
        super.tearDown()
    }

    func test_activity_createNew() {
        sut.createObject(fakeActivity)
        let activity: Activity = sut.retrieveObject(fakeActivity.resourceId)!
        
        XCTAssertEqual(activity.name, "Morning shower")
        XCTAssertEqual(activity.type, ActivityType.routine)
        XCTAssertEqual(activity.notifications, false)
        XCTAssertEqual(activity.days, [.first, .second, .third])
        XCTAssertEqual(activity.stats.averageSuccess, 0)
    }

}
