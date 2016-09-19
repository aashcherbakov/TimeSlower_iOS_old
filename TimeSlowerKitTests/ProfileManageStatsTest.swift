//
//  ProfileManageStatsTest.swift
//  TimeSlower2
//
//  Created by Aleksander Shcherbakov on 7/3/15.
//  Copyright (c) 2015 1lastDay. All rights reserved.
//

import UIKit
import XCTest
import CoreData
@testable import TimeSlowerKit

class ProfileManageStatsTest: CoreDataBaseTest {
    
    var testDateFormatter: DateFormatter!
    var timeMachine: TimeMachine!
    var testResult: DayResults!
    
    //MARK: - Setup
    
    override func setUp() {
        super.setUp()
        
        testResult = testCoreDataStack.fakeResultForActivity(testActivity)
        testDateFormatter = testCoreDataStack.shortStyleDateFormatter()
        timeMachine = TimeMachine()
    }
    
    override func tearDown() {
        testCoreDataStack = nil
        testContext = nil
        testProfile = nil
        testActivity = nil
        testDateFormatter = nil
        super.tearDown()
    }
    
    // MARK: - Default values
    
    func testDefaultBirthday() {
        XCTAssertEqual(testProfile.birthday, DayResults.standardDateFormatter().date(from: "3/28/87")!, "Default birthday should be 28 of march")
    }
    
    func testDefaultCountry() {
        XCTAssertEqual(testProfile.country, "United States", "Default country should be US")
    }
    
    // MARK: - Profile properties
    
    func testUserAge() {
        XCTAssertEqual(testProfile.userAge(), 29, "User age must be 29")
    }
    
    func testUserGender() {
        XCTAssertEqual(testProfile.userGender(), Profile.Gender.male, "User gender should be male")
    }
    
    func testUserGenderString() {
        XCTAssertEqual(testProfile.userGenderString(), "Male", "User gender should be male")
    }
    
    func testGenderWithEnum() {
        testProfile.gender = Profile.genderWithEnum(.female)
        XCTAssertEqual(testProfile.gender, 1, "Gender must change to female")
    }
    
    func testYearsLeftForProfile() {
        XCTAssertGreaterThan(testProfile.yearsLeftForProfile(), 48, "Years left should be more than 48")
    }
    
    func testMaxYearsLeftForProfile() {
        XCTAssertEqual(testProfile.maxYearsForProfile(), 77.4, "Max years should be 77.4")
    }
    
    func testDateOfApproximateLifeEnd() {
        let dateOfDeathString = DayResults.standardDateFormatter().string(from: testProfile.dateOfApproximateLifeEnd())
        XCTAssertEqual(dateOfDeathString, "3/28/64", "Date of death should be March 2064")
    }

    //MARK: - Minutes to lifetime conversion
    
    func testNumberOfDaysTillEndOfLife() {
        XCTAssertGreaterThan(testProfile.numberOfDaysTillEndOfLifeSinceDate(Date()), 17000, "Number of days must be greater than 17000")
    }
    
    func testTotalTimeForDailyMinutes() {
        let totalTime = testProfile.totalTimeForDailyMinutes(10)
        XCTAssertGreaterThan(totalTime.hours, 2500, "Number of hours must be greater than 2500")
        XCTAssertGreaterThan(totalTime.days, 100, "Number of days must be greater than 100")
        XCTAssertGreaterThan(totalTime.months, 3, "Number of months must be greater than 3")
        XCTAssertGreaterThan(totalTime.years, 0, "Number of years must be greater than 0")
    }
}
