//
//  ProgressCalculatorTests.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 10/13/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import XCTest
@testable import TimeSlowerKit

class ProgressCalculatorTests: BaseDataStoreTest {
    
    var sut: ProgressCalculator!
    var fakeActivity: Activity!
    var dataStore: DataStore!
    
    override func setUp() {
        super.setUp()
        
        let profile = TestHelper().fakeProfile()
        dataStore = DataStore(withCoreDataStack: fakeCoreDataStack)
        sut = ProgressCalculator(withProfile: profile, dataStore: dataStore)
        fakeActivity = FakeActivityFactory().fakeActivity()
        
        dataStore.create(fakeActivity)
        dataStore.create(profile)

    }
    
    override func tearDown() {
        sut = nil
        fakeActivity = nil
        super.tearDown()
    }
    
    func test_progressForDate() {
        let resultTime = shortTimeFormatter.date(from: "10/11/16, 11:00 AM")!
        let searchDate = shortDateFormatter.date(from: "10/11/16")!

        let result1 = Result(withActivity: fakeActivity, factFinish: resultTime)
        dataStore.create(result1, withParent: fakeActivity)
        
        let savedResult: Result = dataStore.retrieve("10/11/16")!
        XCTAssertNotNil(savedResult)
        
        let success = sut.progressForDate(date: searchDate)
        XCTAssertNotNil(success)
        XCTAssertEqual(success.plannedTime, 10)
        XCTAssertEqual(success.savedTime, 10)
        XCTAssertEqual(success.success, 100)
    }
    
    func test_progressForDate_success() {
        
    }
    
}
