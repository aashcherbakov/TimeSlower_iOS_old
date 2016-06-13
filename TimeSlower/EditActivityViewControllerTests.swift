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
    
    func test_whenOtherCellExpands_afterNameWasNotEntered() { // TODO: this fails to assign first responder for now
        // given
        _ = sut.view
        sut.tableView.reloadData()
        let firstCellIndex = NSIndexPath(forRow: 0, inSection: 0)
        let secondCellIndex = NSIndexPath(forRow: 1, inSection: 0)
        let nameCell = sut.tableView.cellForRowAtIndexPath(firstCellIndex) as! EditNameCell
        let basisCell = sut.tableView.cellForRowAtIndexPath(secondCellIndex) as! EditBasisCell
        let nameCellControl = nameCell.control as! EditActivityNameView
        let nameCellTextfield = nameCellControl.textFieldView.textField

        // when
        nameCell.control.sendActionsForControlEvents(.TouchUpInside)
        nameCellTextfield.becomeFirstResponder()
        let firstCellHeight = sut.tableView.delegate?.tableView!(sut.tableView, heightForRowAtIndexPath: firstCellIndex)
        XCTAssertEqual(firstCellHeight, EditNameCell.expandedHeight, "it should expand cell")

        // and after that
        basisCell.control.sendActionsForControlEvents(.TouchUpInside)
        
        // then
        let updatedFirstCellHeight = sut.tableView.delegate?.tableView!(sut.tableView, heightForRowAtIndexPath: firstCellIndex)
        XCTAssertEqual(updatedFirstCellHeight, EditNameCell.defaultHeight,
                    "it should collapse previousely expanded cell")
        XCTAssertFalse(nameCellTextfield.isFirstResponder(),
                       "it should resign first responder from name cell")
    }
    
    func test_defaultStateWithoutActivity() {
//        XCTAssert<#Equal#>(<#T##expression1: T?##T?#>, <#T##expression2: T?##T?#>, "it should set name cell expanded")
//        XCTAssert<#Equal#>(<#T##expression1: T?##T?#>, <#T##expression2: T?##T?#>, "it should set state to .Name")
//        XCTAssert<#Equal#>(<#T##expression1: T?##T?#>, <#T##expression2: T?##T?#>, "it should set all other cell heights to 0")
    }
    
    func test_changeStateFromNameToBasis() {
//        let firstCellIndex = NSIndexPath(forRow: 0, inSection: 0)
//        let secondCellIndex = NSIndexPath(forRow: 1, inSection: 0)

        _ = sut.view
        sut.tableView.reloadData()
//        
//        XCTAssert<#Equal#>(<#T##expression1: T?##T?#>, <#T##expression2: T?##T?#>, "it should set name cell height to default")
//        XCTAssert<#Equal#>(<#T##expression1: T?##T?#>, <#T##expression2: T?##T?#>, "it should set basis cell to expanded")
//        XCTAssert<#Equal#>(<#T##expression1: T?##T?#>, <#T##expression2: T?##T?#>, "it should leave other cell height as 0")
    }
}
