//
//  ProfileEditingViewModelTests.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 12/31/15.
//  Copyright © 2015 Oleksandr Shcherbakov. All rights reserved.
//

import XCTest
import TimeSlowerKit
@testable import TimeSlower

class ProfileEditingViewModelTests: XCTestCase {

    var viewModel: ProfileEditingViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = ProfileEditingViewModel(withTableView: UITableView())
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }

    func testUserDidPickGender() {
        viewModel.userDidPickGender(0)
        XCTAssertEqual(viewModel.selectedGender, Profile.Gender.Male)
    }
    
//    func testUserDidMissDataTrue() {
//        XCTAssertNotNil(viewModel.userDidMissData(), "Should return string for reason")
//    }
    
    func testUserDidMissDataFalse() {
        viewModel.userDidPickGender(0)
        viewModel.cellConfig?.updateValue("Alex", forType: .Name)
        viewModel.cellConfig?.updateValue("Ukraine", forType: .Country)
        viewModel.cellConfig?.updateValue(NSDate(), forType: .Birthday)
        XCTAssertNil(viewModel.userDidMissData(), "Has no missed data")
    }
}
