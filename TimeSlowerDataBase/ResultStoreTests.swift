//
//  ResultStoreTests.swift
//  TimeSlowerKit
//
//  Created by Alexander Shcherbakov on 9/10/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import XCTest
import TimeSlowerDataBase

class ResultStoreTests: BaseDataStoreTest {

    var sut: ResultStore!
    var stringDate: String!
    var parentActivity: ActivityEntity!
    
    override func setUp() {
        super.setUp()
        sut = ResultStore(withCoreDataStack: fakeCoreDataStack)
        
        let activity: ActivityEntity = ActivityStore(withCoreDataStack: fakeCoreDataStack).createEntity()

        parentActivity = activity
        stringDate = shortDateFormatter.string(from: Date())

    }
    
    override func tearDown() {
        sut = nil
        stringDate = nil
        parentActivity = nil
        super.tearDown()
    }

    func test_createEntityWithParent() {
        let result: ResultEntity = sut.createEntity(withParent: parentActivity)
        XCTAssertEqual(result.activity, parentActivity)
        XCTAssertEqual(result.duration, 0)
        XCTAssertEqual(result.savedTime, 0)
        XCTAssertEqual(result.success, 0)
        XCTAssertEqual(result.stringDate, stringDate)
    }
    

    func test_entityWithKey() {
        let result: ResultEntity = sut.createEntity(withParent: parentActivity)
        let foundResult: ResultEntity = sut.entityForKey(result.stringDate)!
        XCTAssertNotNil(foundResult)
    }
    
    func test_deleteActivity() {
        // given
        let result: ResultEntity = sut.createEntity(withParent: parentActivity)
        
        // when
        sut.deleteEntity(result)
        
        // then
        let foundResult: ResultEntity? = sut.entityForKey(result.stringDate)
        XCTAssertNil(foundResult)
    }
    
    func test_updateEntity() {
        let result: ResultEntity = sut.createEntity(withParent: parentActivity)
        let updatedResult: ResultEntity = sut.updateEntity(result, configuration: configuration())
        
        XCTAssertEqual(updatedResult.activity, parentActivity)
        XCTAssertEqual(updatedResult.duration, 40)
        XCTAssertEqual(updatedResult.savedTime, 30)
        XCTAssertEqual(updatedResult.success, 60)
        XCTAssertEqual(updatedResult.stringDate, "8/29/1999")
    }
    
    func test_retrieveEntities() {
        let result1: ResultEntity = sut.createEntity(withParent: parentActivity)
        let result2: ResultEntity = sut.createEntity(withParent: parentActivity)
        let _: ResultEntity = sut.updateEntity(result1, configuration: configuration())
        let _: ResultEntity = sut.updateEntity(result2, configuration: configuration())

        let result: ResultEntity = sut.entityForKey("8/29/1999")!
        XCTAssertEqual(result.stringDate, "8/29/1999")
        
        let results: [ResultEntity] = sut.entitiesForKey("8/29/1999")!
        XCTAssertEqual(results.count, 2)
    }
    
    // MARK: - Helper functions
    
    func configuration() -> ResultConfiguration {
        return ResultConfiguration(
            stringDate: "8/29/1999",
            duration: 40,
            startTime: Date(),
            finishTime: Date(),
            savedTime: 30,
            success: 60,
            date: Date(),
            resourceId: "12345")
    }

}
