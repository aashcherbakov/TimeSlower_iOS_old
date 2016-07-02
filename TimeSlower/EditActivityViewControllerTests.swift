//
//  EditActivityViewControllerTests.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 5/30/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import XCTest
@testable import TimeSlower

class EditActivityViewControllerTests: XCTestCase {

    var sut: EditActivityVC!
    
    override func setUp() {
        super.setUp()
        let controller: EditActivityVC = ControllerFactory.createController()
        sut = controller
        _ = sut.view
        sut.tableView.reloadData()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    // MARK: - Setup
    
    func test_SUTInitialSetup() {
        // when
        _ = sut.view
        
        // then
        XCTAssertNotNil(sut, "it should be instantiated")
        XCTAssertNotNil(sut.tableView, "it should have tableView")
        XCTAssertTrue(sut.tableView.delegate is EditActivityVC, "it should setup tableView delegate")
        XCTAssertTrue(sut.tableView.dataSource is EditActivityVC, "it should setup tableView data source")
    }
    
    // MARK: - Data Source
    
    func test_DataSourceSetup() {
        // when
        _ = sut.view
        
        // then
        XCTAssertEqual(sut.tableView.numberOfSections, 1, "it should have one section")
        XCTAssertEqual(sut.tableView.numberOfRowsInSection(0), 6, "it should have 6 rows")
    }
    
    func test_setupNameCell() {
        // given
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        let cell = sut.tableView.cellForRowAtIndexPath(indexPath)
        
        // then
        XCTAssertTrue(cell is ObservableControlCell, "it should have first cell as Observable")
        XCTAssertTrue(cell is ExpandableCell, "it should be expandable")
        XCTAssertEqual(sut.tableView.delegate?.tableView!(sut.tableView, heightForRowAtIndexPath: indexPath), EditNameCell.defaultHeight, "it should be default height for cell")
    }
    
    // MARK: - Expand Cells
    
    func test_expandCell() {
        // given
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)

        // when
        let cell = sut.tableView.cellForRowAtIndexPath(indexPath) as! ObservableControlCell
        cell.control.sendActionsForControlEvents(.TouchUpInside)
        let cellHeight = sut.tableView.delegate?.tableView!(sut.tableView, heightForRowAtIndexPath: indexPath)
        
        // then
        XCTAssertEqual(cellHeight, EditNameCell.expandedHeight, "it should set height to expanded value")
    }
    
    func test_collapseNameCell() {
        // given
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        
        // when
        _ = sut.view
        sut.tableView.reloadData()
        let cell = sut.tableView.cellForRowAtIndexPath(indexPath) as! EditNameCell
        let nameView = cell.control as? EditActivityNameView
        nameView?.textFieldView.textField.resignFirstResponder()
        
        let cellHeight = sut.tableView.delegate?.tableView!(sut.tableView, heightForRowAtIndexPath: indexPath)

        // then
        XCTAssertEqual(cellHeight, EditNameCell.defaultHeight, "it should be default height for cell")
    }

}
