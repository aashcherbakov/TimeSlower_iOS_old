//
//  TextfieldViewTests.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 2/7/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import XCTest
@testable import TimeSlower

class TextfieldViewTests: XCTestCase {

    var fakeController: FakeControllerWithCustomViews!
    var sut: TextfieldView!
    var fakeDelegate: FakeTextfieldViewDelegate!
    
    override func setUp() {
        super.setUp()
        
        // Setup fake controller
        let controller: FakeControllerWithCustomViews = FakeStoryboardLoader.testViewController()
        fakeController = controller
        sut = fakeController.textfieldView
        fakeDelegate = FakeTextfieldViewDelegate()
    }
    
    override func tearDown() {
        fakeDelegate = nil
        sut = nil
        fakeController = nil
        
        super.tearDown()
    }

    func testThat_whenThereIsNoText() {
        // given
        sut.setup(withType: .ActivityName, delegate: fakeDelegate)
        
        // when
        sut.setText("Test text")

        // then
        XCTAssertEqual(sut.textField.textColor, UIColor.darkGray(),
            "it should set text color to black")
        XCTAssertEqual(sut.imageView.image, UIImage(named: "activityNameIconBlack"),
            "it should change icon to black one")
    }
    
    func testThat_withoutAnyData() {
        // given
        sut.setup(withType: .ActivityName, delegate: fakeDelegate)
        
        // then
        XCTAssertEqual(sut.imageView.image, UIImage(named: "activityNameIcon"),
            "it should have gray image")
        XCTAssertEqual(sut.textField.placeholder, "Activity name",
            "it should have placeholder Activity name")
    }
    
    func testThat_whenUserTappedEnterButton() {
        // given
        sut.setup(withType: .ActivityName, delegate: fakeDelegate)
        
        // when
        sut.setText("Test text")
        sut.textFieldShouldReturn(sut.textField)
        
        // then
        XCTAssertTrue(fakeDelegate.textFieldViewDidReturnCalled,
            "it should send delegate message to delegate")
        XCTAssertEqual(fakeDelegate.textFieldText, "Test text",
            "it should pass entered text as an argument")
        XCTAssertFalse(sut.textField.isFirstResponder(),
            "it should resign first responder")
    }
    
    func testThat_whenUserStartsEnteringText() {
        // given
        sut.setup(withType: .ActivityName, delegate: fakeDelegate)
        
        // when
        sut.textField.becomeFirstResponder()
        
        // then
        XCTAssertTrue(fakeDelegate.textFieldViewDidBeginEditingCalled,
            "it should notify delegate")
        XCTAssertEqual(sut.imageView.image, UIImage(named: "activityNameIcon"),
            "it should still have gray icon")
    }
}

class FakeTextfieldViewDelegate: TextFieldViewDelegate {
    var textFieldViewDidReturnCalled = false
    var textFieldText = ""
    var textFieldViewDidBeginEditingCalled = false
    
    func textFieldViewDidReturn(withText: String) {
        textFieldViewDidReturnCalled = true
        textFieldText = withText
    }
    
    func textFieldViewDidBeginEditing() {
        textFieldViewDidBeginEditingCalled = true
    }
}
