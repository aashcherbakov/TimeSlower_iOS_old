//
//  ProfileEditingCellTests.swift
//  TimeSlower
//
//  Created by Alexander Shcherbakov on 12/8/15.
//  Copyright © 2015 Oleksandr Shcherbakov. All rights reserved.
//

import XCTest
import UIKit
@testable import TimeSlower

class ProfileEditingCellTests: XCTestCase {
    
    var fakeController: FakeControllerWithTableView!
    
    override func setUp() {
        super.setUp()
        
        // Setup fake controller
        let storyboard = UIStoryboard(name: "FakeStoryboard",
            bundle: NSBundle(forClass: FakeControllerWithTableView.classForCoder()))
        let controller = storyboard.instantiateViewControllerWithIdentifier("FakeControllerWithTableView")
            as! FakeControllerWithTableView
        
        self.fakeController = controller
        
        XCTAssertNotNil(controller.view, "View should be loaded")
        XCTAssertNotNil(controller.tableView, "Table view should be loaded")

//        // Setup table view cell
//        self.fakeController.tableView
//            .registerNib(UINib(nibName: "ProfileEditingTableViewCell",
//            bundle: NSBundle(forClass: ProfileEditingTableViewCell.classForCoder())),
//            forCellReuseIdentifier: "ProfileEditingTableViewCell")
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDequeueCell() {
        let cell = self.fakeController.tableView(self.fakeController.tableView,
            cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
        XCTAssertNotNil(cell, "Cell should not be nil")
    }
    
    func testSetupNameCell() {
        
    }
    
    func testSetupCountryCell() {
        
    }
    
    func testSetupBirthdayCell() {
        
    }
}

extension FakeControllerWithTableView : UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        tableView.registerNib(UINib(nibName: "ProfileEditingTableViewCell", bundle: NSBundle(forClass: ProfileEditingTableViewCell.classForCoder())), forCellReuseIdentifier: "ProfileEditingTableViewCell")
        
        return self.tableView.dequeueReusableCellWithIdentifier("ProfileEditingTableViewCell")!
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
}
