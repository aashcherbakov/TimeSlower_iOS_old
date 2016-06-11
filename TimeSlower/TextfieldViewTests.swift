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
    
    override func setUp() {
        super.setUp()
        
        // Setup fake controller
        let controller: FakeControllerWithCustomViews = FakeStoryboardLoader.testViewController()
        fakeController = controller
        sut = fakeController.textfieldView
        sut.setupWithConfig(NameTextfield())
    }
    
    override func tearDown() {
        sut = nil
        fakeController = nil
        
        super.tearDown()
    }

    func testThat_whenThereIsNoText() {
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
        sut.setupWithConfig(NameTextfield())
        
        // then
        XCTAssertEqual(sut.imageView.image, UIImage(named: "activityNameIcon"),
            "it should have gray image")
        XCTAssertEqual(sut.textField.placeholder, "Activity name",
            "it should have placeholder Activity name")
    }
    
    func testThat_whenUserTappedEnterButton() {
        // given
        sut.setupWithConfig(NameTextfield())
        
        // when
        sut.setText("Test text")
        sut.textField.resignFirstResponder()
        
        // then
        XCTAssertFalse(sut.textField.isFirstResponder(),
            "it should resign first responder")
    }
    
    func testThat_whenUserStartsEnteringText() {
        // given
        
        // when
        sut.textField.becomeFirstResponder()
        
        // then
        XCTAssertEqual(sut.imageView.image, UIImage(named: "activityNameIcon"),
            "it should still have gray icon")
    }
}
