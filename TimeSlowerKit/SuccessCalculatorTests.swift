//
//  SuccessCalculatorTests.swift
//  TimeSlowerKit
//
//  Created by Oleksandr Shcherbakov on 9/4/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import XCTest
@testable import TimeSlowerKit

class SuccessCalculatorTests: XCTestCase {
    
    var sut: SuccessCalculator!
    var testStartDate: Date!
    var testFinishDate: Date!

    override func setUp() {
        super.setUp()
        sut = SuccessCalculator()
        
        let shortTimeFormatter = StaticDateFormatter.shortDateAndTimeFormatter
        let testDateString = "8/21/16"
        testStartDate = shortTimeFormatter.date(from: "\(testDateString), 10:15 AM")
        testFinishDate = shortTimeFormatter.date(from: "\(testDateString), 10:45 AM")
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Success calculation for Routine
    
    func test_successForRoutine_noSuccess() {
        let result = sut.successForRoutine(start: testStartDate, finish: testFinishDate, maxDuration: 30, goal: 10)
        XCTAssertEqual(result, 0, "it should have no success at all")
    }
    
    func test_successForRoutine_fullSuccess() {
        let result = sut.successForRoutine(start: testStartDate, finish: testFinishDate, maxDuration: 40, goal: 10)
        XCTAssertEqual(result, 100, "it should have 100% success")
    }
    
    func test_successForRoutine_someSuccess() {
        let result = sut.successForRoutine(start: testStartDate, finish: testFinishDate, maxDuration: 35, goal: 10)
        XCTAssertEqual(result, 50, "it should have 50% success")
    }
    
    func test_successForRoutine_superSuccess() {
        let result = sut.successForRoutine(start: testStartDate, finish: testFinishDate, maxDuration: 50, goal: 10)
        XCTAssertEqual(result, 200, "it should have 200% success")
    }
    
    func test_successForRoutine_negativeSuccess() {
        let result = sut.successForRoutine(start: testStartDate, finish: testFinishDate, maxDuration: 20, goal: 10)
        XCTAssertEqual(result, 0, "it should have no success")
    }
    
    // MARK: - Success calculation for Goal
    
    func test_successForGoal_fullSuccess() {
        let result = sut.successForGoal(start: testStartDate, finish: testFinishDate, maxDuration: 30, goal: 10)
        XCTAssertEqual(result, 100)
    }
    
    func test_successForGoal_noSuccess() {
        let result = sut.successForGoal(start: testStartDate, finish: testStartDate, maxDuration: 30, goal: 10)
        XCTAssertEqual(result, 0)
    }
    
    func test_successForGoal_superSuccess() {
        let result = sut.successForGoal(start: testStartDate, finish: testFinishDate, maxDuration: 20, goal: 10)
        XCTAssertEqual(result, 150)
    }
}
