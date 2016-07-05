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
        XCTAssertTrue(sut.textFieldView.config is BasisTextfield,
                      "it should set textfield type to Basis")
        XCTAssertNil(sut.basisSelector.selectedIndex,
                     "it should not have selected value")
        XCTAssertNil(sut.selectedValue,
                     "it should not have selected days")
    }
    
    func test_selectedValueSetFromOutside() {
        // when
        sut.selectedBasis = Basis.Weekends
        
        // then
        XCTAssertEqual(sut.textFieldView.textField.text, "Saturday and Sunday",
                       "it should set textfield text to Weekends")
        XCTAssertNil(sut.basisSelector.selectedIndex,
                     "it should not set selected segment index")
        
    }
}