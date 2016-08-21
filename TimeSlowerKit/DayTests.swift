//
//  DayTests.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 8/21/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import XCTest
import TimeSlowerKit

class DayTests: CoreDataBaseTest {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func test_createFromWeekday() {
        let weekday = Weekday(rawValue: 0) // Sunday

        let day = Day.createFromWeekday(weekday!, forActivity: testActivity)
        XCTAssertEqual(day?.name, "Sun")
        XCTAssertEqual(day?.number, 0)
    }
    
    func test_daysIntegerRepresentation() {
        let day1 = Day.createFromWeekday(Weekday(rawValue: 0)!, forActivity: testActivity)!
        let day2 = Day.createFromWeekday(Weekday(rawValue: 1)!, forActivity: testActivity)!
        
        let integerRepresentation = Day.daysIntegerRepresentation(Set([day1, day2]))
        
        XCTAssertTrue(integerRepresentation.contains(0))
        XCTAssertTrue(integerRepresentation.contains(1))
        XCTAssertEqual(integerRepresentation.count, 2)
    }
    
    func test_daysEntitiesFromSelectedDays() {
        let result = Day.dayEntitiesFromSelectedDays([1, 2], forActivity: testActivity)
        XCTAssertEqual(result.count, 2)
    }
}
