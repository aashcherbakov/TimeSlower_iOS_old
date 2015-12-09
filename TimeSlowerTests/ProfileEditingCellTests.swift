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

    var fakeController: FakeControllerWithTableView!
    
    override func setUp() {
        super.setUp()
        
        // Setup fake controller
        let storyboard = UIStoryboard(name: "FakeStoryboard",
            bundle: NSBundle(forClass: FakeControllerWithTableView.classForCoder()))
        
        let controller = storyboard.instantiateInitialViewController()
            as! FakeControllerWithTableView
        
        XCTAssertNotNil(controller.view, "View should be loaded")
        XCTAssertNotNil(controller.tableView, "Table view should be loaded")
        
        self.fakeController = controller
        
        let realBundle = NSBundle.mainBundle()
        self.fakeController.tableView
            .registerNib(UINib(nibName: "ProfileEditingTableViewCell",
            bundle: realBundle),
            forCellReuseIdentifier: "ProfileEditingTableViewCell")
        }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

}
