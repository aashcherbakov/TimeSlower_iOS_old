//
//  BasisSelectorTests.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 6/19/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import XCTest
@testable import TimeSlower


class BasisSelectorTests: XCTestCase {

    var sut: BasisSelector!
    
    override func setUp() {
        super.setUp()
        
        let controller: FakeControllerWithCustomViews = FakeStoryboardLoader.testViewController()
        _ = controller.view
        sut = controller.basisSelector
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    
    func test_buttonTouch() {
        // when
        sut.dailyOptionView.button.sendActionsForControlEvents(.TouchUpInside)
        
        // then
        XCTAssertEqual(sut.selectedIndex, 0,
                       "it should set selected value to 0")
        XCTAssertFalse(sut.workdaysOptionView.optionSelected,
                       "it should deselect second button")
        XCTAssertFalse(sut.weekendsOptionView.optionSelected,
                       "it should deselect third button")
    }
    
    func test_setRandomBasis() {
        // when
        sut.updateSegmentedIndexForBasis(.Random)
        
        // then
        XCTAssertFalse(sut.dailyOptionView.optionSelected,
                       "it should deselect first button")
        XCTAssertFalse(sut.workdaysOptionView.optionSelected,
                       "it should deselect second button")
        XCTAssertFalse(sut.weekendsOptionView.optionSelected,
                       "it should deselect third button")
    }
    
    func test_changeSelectedIndexWithButton() {
        // given
        sut.workdaysOptionView.optionSelected = true
        
        // when
        sut.weekendsOptionView.button.sendActionsForControlEvents(.TouchUpInside)
        
        // then
        XCTAssertEqual(sut.selectedIndex, 2,
                    "it should set selected index to weekends")
        XCTAssertFalse(sut.workdaysOptionView.optionSelected,
                       "it should deselect workdays button")
    }
}
