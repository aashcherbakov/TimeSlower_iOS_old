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
        sut = Profile(name: "Alex", country: "United States", dateOfBirth: shortDateFormatter.date(from: "3/28/1987")!, gender: .male, maxAge: 79.0, photo: nil)
    }
    
    override func tearDown() {
        shortDateFormatter = nil
        sut = nil
        super.tearDown()
    }

    func test_userAge() {
        let targetDate = shortDateFormatter.date(from: "9/1/2016")!
        XCTAssertEqual(sut.userAgeForDate(targetDate), 29)
    }
    
    func testUserGenderString() {
        XCTAssertEqual(sut.genderDescription(), "Male", "User gender should be male")
    }

    func testDateOfApproximateLifeEnd() {
        let dateOfDeathString = shortDateFormatter.string(from: sut.dateOfApproximateLifeEnd())
        XCTAssertEqual(dateOfDeathString, "3/28/66", "Date of death should be March 2064")
    }
    
    func testNumberOfDaysTillEndOfLife() {
        let targetDate = shortDateFormatter.date(from: "9/1/2016")!
        XCTAssertEqual(sut.numberOfDaysTillEndOfLifeSinceDate(targetDate), 18105, "Number of days must be greater than 18105")
    }
}
