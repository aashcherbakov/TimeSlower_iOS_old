

//
//  ProfileStatsCalculatorTests.swift
//  TimeSlowerKit
//
//  Created by Oleksandr Shcherbakov on 9/3/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import XCTest
import TimeSlowerKit

class ProfileStatsCalculatorTests: XCTestCase {

    var sut: ProfileStatsCalculator!
    override func setUp() {
        super.setUp()

        sut = ProfileStatsCalculator()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Saved
    
    func test_savedTimeInPeriod_Today() {
        let savedTime = sut.savedTimeInPeriod(.today)
        XCTAssertEqual(savedTime, 0)
    }
    
    func test_savedTimeInPeriod_Overall() {
        let savedTime = sut.savedTimeInPeriod(.overall)
        XCTAssertEqual(savedTime, 0)
    }
    
    // MARK: - Spent
    
    func test_spentTimeInPeriod_Today() {
        let spentTime = sut.spentTimeInPeriod(.today)
        XCTAssertEqual(spentTime, 0)
    }
    
    func test_spendTimeInPeriod_Overall() {
        let spentTime = sut.spentTimeInPeriod(.overall)
        XCTAssertEqual(spentTime, 0)
    }
    
    // MARK: - Saving Goal
    
    func test_savingGoal_Today() {
        let savingGoal = sut.savingGoalForPeriod(.today)
        XCTAssertEqual(savingGoal, 0)
    }
    
    func test_savingGoal_Overall() {
        let savingGoal = sut.savingGoalForPeriod(.overall)
        XCTAssertEqual(savingGoal, 0)
    }
    
    // MARK: - Spending Goal
    
    func test_spendingGoal_Today() {
        let spendingGoal = sut.spentTimeInPeriod(.today)
        XCTAssertEqual(spendingGoal, 0)
    }
    
    func test_spendingGoal_Overall() {
        let spendingGoal = sut.spentTimeInPeriod(.overall)
        XCTAssertEqual(spendingGoal, 0)
    }

}
