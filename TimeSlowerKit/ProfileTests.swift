//
//  ProfileTests.swift
//  TimeSlowerKit
//
//  Created by Oleksandr Shcherbakov on 9/2/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import XCTest
import TimeSlowerKit

class ProfileTests: XCTestCase {

    var sut: Profile!
    var shortDateFormatter: DateFormatter!
    
    override func setUp() {
        super.setUp()
        shortDateFormatter = StaticDateFormatter.shortDateNoTimeFromatter
        sut = FakeFactory.profile()
    }
    
    override func tearDown() {
        shortDateFormatter = nil
        sut = nil
        super.tearDown()
    }

    func test_initWithProfile() {
        let newProfile = Profile(fromProfile: sut, name: "Billy", dateOfBirth: Date(), country: "Uraguai", photo: nil)
        XCTAssertEqual(newProfile.gender, .male)
        XCTAssertEqual(newProfile.maxAge, 79)
        XCTAssertEqual(newProfile.name, "Billy")
        XCTAssertEqual(newProfile.country, "Uraguai")
    }
    
    func test_userAge() {
        let targetDate = shortDateFormatter.date(from: "9/1/2016")!
        XCTAssertEqual(sut.userAgeForDate(targetDate), 29)
    }
    
    func test_userGenderString() {
        XCTAssertEqual(sut.genderDescription(), "Male", "User gender should be male")
    }

    func test_dateOfApproximateLifeEnd() {
        let dateOfDeathString = shortDateFormatter.string(from: sut.dateOfApproximateLifeEnd())
        XCTAssertEqual(dateOfDeathString, "3/28/66", "Date of death should be March 2064")
    }
    
    func test_numberOfDaysTillEndOfLife() {
        let targetDate = shortDateFormatter.date(from: "9/1/2016")!
        XCTAssertEqual(sut.numberOfDaysTillEndOfLifeSinceDate(targetDate), 18105, "Number of days must be greater than 18105")
    }
    
    func test_defaultBirthday() {
        let testDate = shortDateFormatter.date(from: "03/28/1987")
        XCTAssertEqual(testDate, Profile.defaultBirthday())
    }
}
