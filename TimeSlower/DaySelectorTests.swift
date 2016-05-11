//
//  DaySelectorTests.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 2/7/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import XCTest
@testable import TimeSlower
@testable import TimeSlowerKit

class DaySelectorTests: XCTestCase {
    
    var sut: DaySelector!
    
    override func setUp() {
        super.setUp()
        
        let controller: FakeControllerWithCustomViews = FakeStoryboardLoader.testViewController()
        sut = controller.daySelector
        
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testThat_whenBasisIsSetToDaily() {
        // given
        sut.basis = Basis.Daily
                
        // then
        XCTAssertEqual(sut.selectedDays.count, 7,
            "it should have a set of 7 selected days")
        XCTAssertNotNil(sut.backButton,
            "it should display back button")
    }
    
    func testThat_whenBasisIsSetToWeekends() {
        // given
        sut.basis = Basis.Weekends
        
        // then
        XCTAssertEqual(sut.selectedDays.count, 2,
            "it should have 2 selected days")
    }
    
    func testThat_whenBackButtonIsTapped() {
        // given
        sut.basis = Basis.Weekends
        
        // when
        sut.backButton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
        
        // then
        XCTAssertEqual(sut.selectedDays.count, 2,
            "it should have 2 selected days in the set")
        XCTAssertEqual(sut.selectedDays, [.First, .Seventh],
                           "it should contain sunday and saturday")
    }
    
    func testThat_whenDayIsDesected() {
        // given
        sut.basis = Basis.Workdays
        
        // when
        let mondayButton = buttonWithName("Mon", fromArray: sut.dayButtons)
        XCTAssertNotNil(mondayButton)
        mondayButton?.sendActionsForControlEvents(.TouchUpInside)
        
        // then
        XCTAssertEqual(sut.selectedDays.count, 4,
            "it should still contain 4 other days")
        XCTAssertFalse(mondayButton!.selected,
            "it should leave button deselected")
    }
    
    func testThat_whenDayIsDeselected() {
        // given
        sut.basis = Basis.Weekends
        deselectAllButtons(sut.dayButtons)
        
        // when
        let sundayButton = buttonWithName("Sun", fromArray: sut.dayButtons)
        XCTAssertNotNil(sundayButton)
        sundayButton?.sendActionsForControlEvents(.TouchUpInside)
        
        // then
        XCTAssertEqual(sut.selectedDays.count, 6,
            "it should be the only day selected")
        XCTAssertTrue(sundayButton!.selected,
            "it should leave button selected")
    }
    
    func testThat_whenBasisIsReset() {
        // given
        sut.basis = Basis.Workdays
        
        // when
        selectDays(["Mon", "Tue"], fromArray: sut.dayButtons)
        sut.basis = Basis.Daily
        
        // then
        XCTAssertTrue(areAllButtonsSelected(inArray: sut.dayButtons),
            "it should reset all buttons to selected state")
        XCTAssertTrue(allButtonsHaveCircleForms(sut.dayButtons),
            "it should rerender all buttons to circles")
        XCTAssertEqual(sut.dayButtons.count, 7,
            "it should have 7 active buttons")
    }
    

    // MARK: - Helper Methods
    
    func areAllButtonsSelected(inArray buttons: [UIButton]) -> Bool {
        var allButtonsSelected = true
        for button in buttons {
            allButtonsSelected = button.selected
        }
        return allButtonsSelected
    }
    
    func buttonWithName(name: String, fromArray buttons: [UIButton]) -> UIButton? {
        for button in buttons {
            if button.titleLabel?.text == name {
                return button
            }
        }
        return nil
    }
    
    func deselectAllButtons(buttons: [UIButton]) {
        for button in buttons {
            button.sendActionsForControlEvents(.TouchUpInside)
        }
    }
    
    func selectDays(days: [String], fromArray buttons: [UIButton]) {
        for day in days {
            let button = buttonWithName(day, fromArray: buttons)
            button?.sendActionsForControlEvents(.TouchUpInside)
        }
    }
    
    func allButtonsHaveCircleForms(buttons: [UIButton]) -> Bool {
        let goodRadius = buttons[0].bounds.height / 2
        for button in buttons {
            if button.layer.cornerRadius != goodRadius {
                return false
            }
        }
        return true
    }
}
