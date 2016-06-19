//
//  EditActivityNameViewTests.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 4/24/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import XCTest
@testable import TimeSlower

class EditActivityNameViewTests: XCTestCase {
    
    var sut: EditActivityNameView!
    var controller: FakeController!
    
    override func setUp() {
        super.setUp()
        
        let controller: FakeControllerWithCustomViews = FakeStoryboardLoader.testViewController()
        self.controller = controller
        sut = controller.editActivityNameView
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func test_initialSetupOfView() {
        // then
        XCTAssertNil(sut.selectedValue,
                       "it should set selected name to nil")
        XCTAssertTrue(sut.textFieldView.config is NameTextfield,
                      "it should set textfield type to Basis")
    }
    
    func test_selectedNameIsSetFromOutside() {
        // when
        sut.selectedValue = "Alex"
        
        // then
        XCTAssertEqual(sut.textFieldView.textField.text, "Alex",
                       "it should set textfield text to Alex")
    }
    
    func test_whenUserTappedDoneOnKeyboard() {
        // given
        sut.selectedValue = "Alex"
        
        // when
        sut.textFieldView.textField.resignFirstResponder()
        
        // then
        XCTAssertEqual(sut.textFieldView.textField.text, "Alex",
                       "it should set textfield text to Alex")
        XCTAssertEqual(sut.selectedValue, "Alex",
                       "it should set selected value to Alex")
    }
}
