//
//  DataStoreTests.swift
//  TimeSlowerKit
//
//  Created by Oleksandr Shcherbakov on 9/2/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import XCTest
import TimeSlowerKit
import TimeSlowerDataBase

class DataStoreTests: XCTestCase {
    
    var sut: DataStore!
    var shortDateFormatter: DateFormatter!
    
    var fakeActivity: Activity!
    
    override func setUp() {
        super.setUp()
        sut = DataStore(withCoreDataStack: FakeCoreDataStack())
        shortDateFormatter = StaticDateFormatter.shortDateNoTimeFromatter
        fakeActivity = TestHelper().fakeActivity()
        
    }
    
    override func tearDown() {
        sut = nil
        shortDateFormatter = nil
        fakeActivity = nil
        super.tearDown()
    }
    
    
    func test_createProfile() {
        let dummyProfile = Profile(name: "Olga", country: "Ukraine", dateOfBirth: shortDateFormatter.date(from: "8/29/1990")!, gender: .female, maxAge: 79.0, photo: nil)

        sut.create(dummyProfile)
        
        let profile: Profile = sut.retrieve(dummyProfile.resourceId)!
        
        XCTAssertEqual(profile.name, "Olga")
        XCTAssertEqual(profile.country, "Ukraine")
        XCTAssertEqual(profile.dateOfBirth, shortDateFormatter.date(from: "8/29/1990"))
        XCTAssertEqual(profile.gender, Gender.female)
        XCTAssertEqual(profile.maxAge, 76.5)
        XCTAssertNil(profile.photo)
    }
    
    func test_updateProfile() {
        // given
        let dummyProfile = Profile(name: "Olga", country: "Ukraine", dateOfBirth: shortDateFormatter.date(from: "8/29/1990")!, gender: .female, maxAge: 79.0, photo: nil)
        sut.create(dummyProfile)
        let profileAlex = Profile(name: "Alex", country: "United States", dateOfBirth: shortDateFormatter.date(from: "3/28/1987")!, gender: .male, maxAge: 79.0, photo: nil, resourceId: dummyProfile.resourceId)
        
        // when
        let updatedProfile: Profile = sut.update(profileAlex)
        
        // then
        XCTAssertEqual(updatedProfile.name, "Alex")
        XCTAssertEqual(updatedProfile.country, "United States")
        XCTAssertEqual(updatedProfile.dateOfBirth, shortDateFormatter.date(from: "3/28/1987"))
        XCTAssertEqual(updatedProfile.gender, Gender.male)
        XCTAssertEqual(updatedProfile.maxAge, 77.4)
        XCTAssertNil(updatedProfile.photo)
    }
    
    func test_retrieveProfile() {
        // given
        let profile = Profile(name: "Olga", country: "Ukraine", dateOfBirth: shortDateFormatter.date(from: "8/29/1990")!, gender: .female, maxAge: 79.0, photo: nil)
        sut.create(profile)
        
        // when
        let retrievedProfile: Profile = sut.retrieve(profile.resourceId)!
        
        // then
        XCTAssertEqual(retrievedProfile.name, "Olga")
        XCTAssertEqual(retrievedProfile.country, "Ukraine")
        XCTAssertEqual(retrievedProfile.dateOfBirth, shortDateFormatter.date(from: "8/29/1990"))
        XCTAssertEqual(retrievedProfile.gender, Gender.female)
        XCTAssertEqual(retrievedProfile.maxAge, 76.5)
        XCTAssertNil(retrievedProfile.photo)
    }
    
    // MARK: - All Activities

    func test_activitiesForDate() {
        // given
        sut.create(fakeActivity)
        let monday = shortDateFormatter.date(from: "9/19/2016")!
        
        // when
        let activities = sut.activities(forDate: monday, type: .routine)
        
        // then
        XCTAssertEqual(activities.count, 1)
        XCTAssertEqual(activities.first!.name, fakeActivity.name)
    }
    
    func test_activitiesForDate_False() {
        // given
        sut.create(fakeActivity)
        let saturday = shortDateFormatter.date(from: "9/17/2016")!
        
        // when
        let activities = sut.activities(forDate: saturday, type: .routine)
        
        // then
        XCTAssertEqual(activities.count, 0)
    }
}
