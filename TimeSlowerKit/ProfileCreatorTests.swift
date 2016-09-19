//
//  ProfileCreatorTests.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 8/28/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import XCTest
@testable import TimeSlowerKit

class ProfileCreatorTests: CoreDataBaseTest {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func test_userProfileInManagedContext() {
        XCTAssertEqual(testProfile.birthday, DayResults.standardDateFormatter().date(from: "3/28/87")!, "Default birthday should be 28 of march")
        XCTAssertEqual(testProfile.country, "United States", "Default country should be US")
        XCTAssertEqual(testProfile.gender, Profile.genderWithEnum(.male), "Default gender is male")
        XCTAssertNotNil(testProfile.dateOfDeath, "Date of death should not be nil")
    }
}
