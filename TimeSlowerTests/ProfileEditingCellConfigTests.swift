//
//  ProfileEditingCellConfigTests.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 12/31/15.
//  Copyright © 2015 Oleksandr Shcherbakov. All rights reserved.
//

import XCTest
@testable import TimeSlower

class ProfileEditingCellConfigTests: XCTestCase {

    var config: ProfileEditingCellConfig!
    
    override func setUp() {
        super.setUp()
        config = ProfileEditingCellConfig(withProfile: nil)
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testUpdateValueForType() {
        config.updateValue("Ukraine" as AnyObject?, forType: .Country)
        XCTAssertEqual(config.country, "Ukraine", "Country should be changed to Ukraine")
    }
    
    func testUpdateBirthdayValueWithString() {
        config.updateValue("11/11/11" as AnyObject?, forType: .Birthday)
//        XCTAssertNotEqual(config.birthday, "11/11/11", "Birthday should not be updated by string")
    }
    
    func testUpdateBirthday() {
        let date = Date()
        config.updateValue(date as AnyObject?, forType: .Birthday)
        XCTAssertEqual(date, config.birthday, "Birthday should be today")
    }
    
    func testUpdateName() {
        config.updateValue("Alex" as AnyObject?, forType: .Name)
        XCTAssertEqual(config.name, "Alex", "Name should be Alex")
    }
    
    func testUpdateNameWithNil() {
        config.updateValue("Alex" as AnyObject?, forType: .Name)
        config.updateValue(NSNull(), forType: .Name)
        XCTAssertEqual(config.name, "Alex", "Method should not set name to nil")
    }
    
    func testInitWithoutProfile() {
        // If user has no profile, all properties are nil
        XCTAssertNil(config.country)
        XCTAssertNil(config.birthday)
        XCTAssertNil(config.name)
    }
    
    func testIconForNameCell() {
        let defaultIcon = config.iconForCellType(.Name, forState: .default)
        XCTAssertEqual(defaultIcon, UIImage(named: "nameIcon"))
        
        let selectedIcon = config.iconForCellType(.Name, forState: .editing)
        XCTAssertEqual(selectedIcon, UIImage(named: "nameIconBlack"))
    }
    
    func testIconForCountryCell() {
        let defaultIcon = config.iconForCellType(.Country, forState: .default)
        XCTAssertEqual(defaultIcon, UIImage(named: "countryIcon"))
        
        let selectedIcon = config.iconForCellType(.Country, forState: .editing)
        XCTAssertEqual(selectedIcon, UIImage(named: "countryIconBlack"))
    }
    
    func testIconForBirthdayCell() {
        let defaultIcon = config.iconForCellType(.Birthday, forState: .default)
        XCTAssertEqual(defaultIcon, UIImage(named: "birthdayIcon"))
        
        let selectedIcon = config.iconForCellType(.Birthday, forState: .editing)
        XCTAssertEqual(selectedIcon, UIImage(named: "birthdayIconBlack"))
    }
    
    func testTextColorForStyle() {
        let defaultStyle = config.textColorForState(.default)
        XCTAssertEqual(defaultStyle, UIColor.lightGray(), "Text should be light gray")
        
        let editingStyle = config.textColorForState(.editing)
        XCTAssertEqual(editingStyle, UIColor.darkGray(), "Text should be dark gray")
    }

}
