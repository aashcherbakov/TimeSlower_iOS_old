//
//  EditActivityBasisViewTests.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 4/24/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import XCTest
@testable import TimeSlower
@testable import TimeSlowerKit

class EditActivityBasisViewTests: XCTestCase {
    
    var sut: EditActivityBasisView!
    var controller: FakeController!
    
    override func setUp() {
        super.setUp()
        
        let controller: FakeControllerWithCustomViews = FakeStoryboardLoader.testViewController()
        self.controller = controller
        sut = controller.editActivityBasisView
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func test_initialSetupOfView() {
        // then
        XCTAssertNil(sut.selectedBasis.value,
                       "it should set selected basis to nil")
        XCTAssertEqual(sut.textFieldView.type, TextFieldViewType.Basis,
                       "it should set textfield type to Basis")
        XCTAssertFalse(sut.expanded.value,
                       "it should not be expended")
    }
    
    func test_userTouchedView() {
        // given
        sut.expanded.value = false
        
        // when
        sut.touchesEnded([UITouch()], withEvent: nil)
        
        // then
        XCTAssertTrue(sut.expanded.value,
                      "it should expand view on touch")
        XCTAssertEqual(sut.selectedBasis.value, ActivityBasis.Daily,
                       "it should set selected daily basis by defatult")
        XCTAssertEqual(sut.textFieldView.textField.text, sut.selectedBasis.value?.description(),
                       "it should set text for textfield")
    }
    
    func test_selectedValueSetFromOutside() {
        // when
        sut.selectedBasis.value = ActivityBasis.Weekends
        
        // then
        XCTAssertEqual(sut.textFieldView.textField.text, "Weekends",
                       "it should set textfield text to Weekends")
        XCTAssertNil(sut.basisSelector.selectedSegmentIndex.value,
                     "it should not set selected segment index")
    }
    
    
}