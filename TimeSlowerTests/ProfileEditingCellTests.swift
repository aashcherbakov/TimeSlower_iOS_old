//
//  ProfileEditingCellTests.swift
//  TimeSlower
//
//  Created by Alexander Shcherbakov on 12/8/15.
//  Copyright © 2015 Oleksandr Shcherbakov. All rights reserved.
//

import XCTest
@testable import TimeSlower

class ProfileEditingCellTests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Setup fake controller
        let storyboard = UIStoryboard(name: "FakeStoryboard",
            bundle: NSBundle(forClass: FakeControllerWithTableView.classForCoder()))
        let controller = storyboard.instantiateViewControllerWithIdentifier("FakeControllerWithTableView")
            as! FakeControllerWithTableView
        
        UIApplication.sharedApplication().keyWindow?.rootViewController = controller
//        self.viewModel = ProfileEditingViewModel(withTableView: controller.tableView)
        
        XCTAssertNotNil(controller.view, "View should be loaded")
        XCTAssertNotNil(controller.tableView, "Table view should be loaded")
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
//    func testDequeueCell() {
//        let cell = viewModel.tableView(viewModel.tableView,
//            cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
//        XCTAssertNotNil(cell, "Cell should not be nil")
//    }
    
    func testSetupNameCell() {
        
    }
    
    func testSetupCountryCell() {
        
    }
    
    func testSetupBirthdayCell() {
        
    }
}
