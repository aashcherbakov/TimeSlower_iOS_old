//
//  ProfileStoreTests.swift
//  TimeSlowerDataBase
//
//  Created by Oleksandr Shcherbakov on 9/1/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import XCTest
import CoreData
import TimeSlowerDataBase

class ProfileStoreTests: BaseDataStoreTest {

    var testCoreDataStack: FakeCoreDataStack!
    var testContext: NSManagedObjectContext!
    var testProfileEntity: ProfileEntity!
    var sut: ProfileStore!
    var birthday: Date!
    
    override func setUp() {
        super.setUp()
        
        // CoreDataStack
        testCoreDataStack = FakeCoreDataStack()
        testContext = testCoreDataStack.managedObjectContext
        shortDateFormatter = DefaultDateFormatter.shortDateNoTimeFromatter
        
        sut = ProfileStore(withCoreDataStack: testCoreDataStack)
        let entity: ProfileEntity = sut.createEntity()
        testProfileEntity = entity
        birthday = shortDateFormatter.date(from: "3/28/1987")

    }
    
    override func tearDown() {
        shortDateFormatter = nil
        testContext = nil
        testCoreDataStack = nil
        testProfileEntity = nil
        birthday = nil
        super.tearDown()
    }

    func test_createEntity_defaultSettings() {
        // when
        let profile: ProfileEntity = sut.createEntity()
        
        // then
        XCTAssertEqual(profile.name, "Anonymous")
        XCTAssertEqual(profile.country, "")
        XCTAssertEqual(profile.gender, 0)
        XCTAssertNotNil(profile.dateOfDeath)
    }
    
    func test_createFakeProfile() {
        XCTAssertNotNil(testProfileEntity)
        XCTAssertEqual(testProfileEntity.name, "Anonymous")
    }
    
    func test_entityForKey() {
        let fetchedProfile: ProfileEntity = sut.entityForKey(testProfileEntity.resourceId)!
        XCTAssertEqual(fetchedProfile.name, "Anonymous")
    }
    
    func test_createEntity_withProfileCreatedBefore() {
        testProfileEntity.name = "Changed name"
        testContext.saveOrRollback()
        XCTAssertEqual(testProfileEntity.name, "Changed name")
        
        let newProfile: ProfileEntity = sut.createEntity()
        XCTAssertEqual(newProfile.name, "Changed name")
    }
    
    func test_deleteEntity() {
        sut.deleteEntity(testProfileEntity)
        
        let foundProfile: ProfileEntity? = sut.entityForKey(testProfileEntity.name)
        XCTAssertNil(foundProfile)
    }
    
    func test_updateEntity() {
        let profile: ProfileEntity = sut.updateEntity(testProfileEntity, configuration: configuration())
        XCTAssertEqual(profile.name, "Alex")
        XCTAssertEqual(profile.birthday, birthday)
        XCTAssertEqual(profile.country, "Ukraine")
        XCTAssertEqual(profile.gender, 0)
        XCTAssertNil(profile.photo)
        XCTAssertEqual(profile.maxAge, 65.5, "it should update max age in case country or birthday is changed")
    }
    
    
    func test_maxYearsLeftForProfile() {
        XCTAssertEqual(testProfileEntity.maxYearsForProfile(testProfileEntity), 76, "Max years should be 77.4")
    }
    

    // MARK: - Helper functions
    
    func configuration() -> ProfileConfiguration {
        let birthday = shortDateFormatter.date(from: "3/28/1987")

        return ProfileConfiguration(name: "Alex", birthday: birthday!, country: "Ukraine", gender: .male, photo: nil, resourceId: "122222")
    }

    
}
