//
//  BasisTests.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 8/14/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import XCTest
import TimeSlowerKit

class BasisTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    // MARK: - basisFromWeekdays()
    
    func test_basisFromWeekends() {
        // given
        let days: [Weekday] = [.first, .seventh]
        
        // when
        let basis = Basis.basisFromWeekdays(days)
        
        // then
        XCTAssertEqual(basis, Basis.weekends,
                       "it should be weekends basis")
    }
    
    func test_basisFromWorkdays() {
        // given
        let days: [Weekday] = [.second, .third, .forth, .fifth, .sixth]
        
        // when
        let basis = Basis.basisFromWeekdays(days)
        
        // then
        XCTAssertEqual(basis, Basis.workdays,
                       "it should be weekends basis")
    }
    
    func test_basisFromDaily() {
        // given
        let days: [Weekday] = [.first, .second, .third, .forth, .fifth, .sixth, .seventh]
        
        // when
        let basis = Basis.basisFromWeekdays(days)
        
        // then
        XCTAssertEqual(basis, Basis.daily,
                       "it should be weekends basis")
    }
    
    func test_basisFromRandom() {
        // given
        let days: [Weekday] = [.first, .sixth, .seventh]
        
        // when
        let basis = Basis.basisFromWeekdays(days)
        
        // then
        XCTAssertEqual(basis, Basis.random,
                       "it should be weekends basis")
    }


}
