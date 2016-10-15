//
//  ProfileAdapterTests.swift
//  TimeSlowerKit
//
//  Created by Oleksandr Shcherbakov on 9/2/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import XCTest
@testable import TimeSlowerKit
@testable import TimeSlowerDataBase

class ProfileAdapterTests: BaseDataStoreTest {

    var sut: ProfileAdapter!
    var fakeProfile: Profile!
    
    override func setUp() {
        super.setUp()
        sut = ProfileAdapter(withCoreDataStack: fakeCoreDataStack)
        fakeProfile = createFakeProfile()
    }
    
    override func tearDown() {
        sut = nil
        fakeProfile = nil
        super.tearDown()
    }

    func test_userProfile_createNew() {
        
        sut.createObject(fakeProfile)
        
        let profile: Profile = sut.retrieveObject(fakeProfile.resourceId)!
        XCTAssertEqual(profile.name, "Anonymous")
        XCTAssertEqual(profile.country, "United States")
        XCTAssertEqual(profile.dateOfBirth, shortDateFormatter.date(from: "3/28/1987"))
        XCTAssertEqual(profile.gender, Gender.male)
        XCTAssertEqual(profile.maxAge, 0.0)
        XCTAssertNil(profile.photo)
    }

    func test_updateProfile() {
        let profile = Profile(name: "Olga", country: "Ukraine", dateOfBirth: shortDateFormatter.date(from: "8/29/1990")!, gender: .female, maxAge: 79.0, photo: nil)
        sut.createObject(profile)
        
        let updatedProfile: Profile = sut.updateObject(profile)
        XCTAssertEqual(updatedProfile.name, "Olga")
        XCTAssertEqual(updatedProfile.country, "Ukraine")
        XCTAssertEqual(updatedProfile.dateOfBirth, shortDateFormatter.date(from: "8/29/1990"))
        XCTAssertEqual(updatedProfile.gender, Gender.female)
        XCTAssertEqual(updatedProfile.maxAge, 76.5)
        XCTAssertNil(updatedProfile.photo)
    }
    
    func test_createProfile_throughDataStore() {
        let testProfile = Profile(name: "Olga", country: "Ukraine", dateOfBirth: shortDateFormatter.date(from: "8/29/1990")!, gender: .female, maxAge: 79.0, photo: nil)

        sut.deleteObject(testProfile)
        sut.createObject(fakeProfile)
        
        let profile: Profile = sut.retrieveObject(fakeProfile.resourceId)!
        
        XCTAssertEqual(profile.name, "Anonymous")
        XCTAssertEqual(profile.country, "United States")
        XCTAssertEqual(profile.dateOfBirth, shortDateFormatter.date(from: "3/28/1987"))
        XCTAssertEqual(profile.gender, Gender.male)
        XCTAssertEqual(profile.maxAge, 0.0)
        XCTAssertNil(profile.photo)
    }
    
    func test_fetchProfile_withEmptyKey() {
        sut.createObject(fakeProfile)
        let profile: Profile = sut.retrieveObject("")!
        
        XCTAssertEqual(profile.name, "Anonymous")
        XCTAssertEqual(profile.country, "United States")
        XCTAssertEqual(profile.dateOfBirth, shortDateFormatter.date(from: "3/28/1987"))
        XCTAssertEqual(profile.gender, Gender.male)
        XCTAssertEqual(profile.maxAge, 0.0)
        XCTAssertNil(profile.photo)

    }
    
    // Helpers
    
    
    /// Profile
    /// - name:     "Anonymous"
    /// - country:  "United States"
    /// - birthday: "3/28/1987"
    /// - gender:   .male
    /// - maxAge:   60
    /// - returns: Profile
    func createFakeProfile() -> Profile {
        return Profile(
            name: "Anonymous", 
            country: "United States", 
            dateOfBirth: shortDateFormatter.date(from: "3/28/1987")!, 
            gender: .male, 
            maxAge: 60, 
            photo: nil)
    }

    

}
