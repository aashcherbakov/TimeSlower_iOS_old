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
        XCTAssertEqual(sut.selectedName.value, "",
                       "it should set selected name to empty string")
        XCTAssertEqual(sut.textFieldView.type, TextFieldViewType.ActivityName,
                       "it should set textfield type to name")
    }
    
    func test_selectedNameIsSetFromOutside() {
        // when
        sut.selectedName.value = "Alex"
        
        // then
        XCTAssertEqual(sut.textFieldView.textField.text, "Alex",
                       "it should set textfield text to Alex")
    }
    
    func test_whenUserTappedDoneOnKeyboard() {
        // given
        sut.selectedName.value = ""
        
        // when
        sut.textFieldViewDidReturn("Alex")
        
        // then
        XCTAssertEqual(sut.textFieldView.textField.text, "Alex",
                       "it should set textfield text to Alex")
        XCTAssertEqual(sut.selectedName.value, "Alex",
                       "it should set selected value to Alex")
    }
}
