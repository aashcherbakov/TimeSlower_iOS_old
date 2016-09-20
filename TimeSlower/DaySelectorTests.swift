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
        sut.selectedBasis = Basis.daily
                
        // then
        XCTAssertEqual(sut.selectedDays.count, 7,
            "it should have a set of 7 selected days")
        XCTAssertNotNil(sut.backButton,
            "it should display back button")
    }
    
    func testThat_whenBasisIsSetToWeekends() {
        // given
        sut.selectedBasis = Basis.weekends
        
        // then
        XCTAssertEqual(sut.selectedDays.count, 2,
            "it should have 2 selected days")
    }
    
    func testThat_whenBackButtonIsTapped() {
        // given
        sut.selectedBasis = Basis.weekends
        
        // when
        sut.backButton.sendActions(for: UIControlEvents.touchUpInside)
        
        // then
        XCTAssertEqual(sut.selectedDays.count, 2,
            "it should have 2 selected days in the set")
        XCTAssertEqual(sut.selectedDays, [Weekday.first.rawValue, Weekday.seventh.rawValue],
                           "it should contain sunday and saturday")
    }
    
    func testThat_whenDayIsDesected() {
        // given
        sut.selectedBasis = Basis.workdays
        
        // when
        let mondayButton = buttonWithName("Mon", fromArray: sut.dayButtons)
        XCTAssertNotNil(mondayButton)
        mondayButton?.sendActions(for: .touchUpInside)
        
        // then
        XCTAssertEqual(sut.selectedDays.count, 4,
            "it should still contain 4 other days")
        XCTAssertFalse(mondayButton!.isSelected,
            "it should leave button deselected")
    }
    
    func testThat_whenDayIsDeselected() {
        // given
        sut.selectedBasis = Basis.weekends
        deselectAllButtons(sut.dayButtons)
        
        // when
        let sundayButton = buttonWithName("Sun", fromArray: sut.dayButtons)
        XCTAssertNotNil(sundayButton)
        sundayButton?.sendActions(for: .touchUpInside)
        
        // then
        XCTAssertEqual(sut.selectedDays.count, 6,
            "it should be the only day selected")
        XCTAssertTrue(sundayButton!.isSelected,
            "it should leave button selected")
    }
    
    func testThat_whenBasisIsReset() {
        // given
        sut.selectedBasis = Basis.workdays
        
        // when
        selectDays(["Mon", "Tue"], fromArray: sut.dayButtons)
        sut.selectedBasis = Basis.daily
        
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
            allButtonsSelected = button.isSelected
        }
        return allButtonsSelected
    }
    
    func buttonWithName(_ name: String, fromArray buttons: [UIButton]) -> UIButton? {
        for button in buttons {
            if button.titleLabel?.text == name {
                return button
            }
        }
        return nil
    }
    
    func deselectAllButtons(_ buttons: [UIButton]) {
        for button in buttons {
            button.sendActions(for: .touchUpInside)
        }
    }
    
    func selectDays(_ days: [String], fromArray buttons: [UIButton]) {
        for day in days {
            let button = buttonWithName(day, fromArray: buttons)
            button?.sendActions(for: .touchUpInside)
        }
    }
    
    func allButtonsHaveCircleForms(_ buttons: [UIButton]) -> Bool {
        let goodRadius = buttons[0].bounds.height / 2
        for button in buttons {
            if button.layer.cornerRadius != goodRadius {
                return false
            }
        }
        return true
    }
}
