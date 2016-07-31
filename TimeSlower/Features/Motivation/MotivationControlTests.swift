//
//  MotivationControlTests.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 7/16/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import XCTest
@testable import TimeSlower
import TimeSlowerKit

class MotivationControlTests: XCTestCase {
    
    var sut: MotivationControl!
    var stats: LifetimeStats!
    var yearStats: LifetimeStats!
    
    override func setUp() {
        super.setUp()
        
        let hours = TimeCalculator().totalHours(inDays: 14600, duration: 20, busyDays: 7)
        stats = LifetimeStats(withHours: hours)
        
        let years = TimeCalculator().totalHours(inDays: 14600, duration: 120, busyDays: 7)
        yearStats = LifetimeStats(withHours: years)
        
        let controller: FakeControllerWithCustomViews = FakeStoryboardLoader.testViewController()
        sut = controller.motivationControl
        controller.view.layoutSubviews()
    }
    
    override func tearDown() {
        sut = nil
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInstantiation() {
        XCTAssertNotNil(sut)
        XCTAssertNotNil(sut.collectionView)
        XCTAssertNotNil(sut.collectionView.delegate)
        XCTAssertNotNil(sut.collectionView.dataSource)
        XCTAssertEqual(sut.view.frame.size, CGSizeMake(202, 150))
    }
    
    func test_collectionViewSetup() {
        sut.setupWithLifetimeStats(stats, shareDelegate: FakeShareDelegate())
        XCTAssertNotNil(sut.stats)
        XCTAssertEqual(sut.collectionView.numberOfItemsInSection(0), 4, "it should have 4 cells")
        XCTAssertEqual(sut.cellTypes!, [.Months, .Days, .Hours, .Share])
    }
    
    // MARK: - Cell Order Layout
    
    func test_cellLayout_ForYearsLessThanOne() {
        // given
        sut.setupWithLifetimeStats(stats, shareDelegate: FakeShareDelegate())
        sut.collectionView.reloadData()
        
        // when
        let firstIndex = NSIndexPath(forItem: 0, inSection: 0)
        let firstCell = sut.collectionView(sut.collectionView, cellForItemAtIndexPath: firstIndex) as! MotivationDotsCollectionViewCell
        let lastIndex = NSIndexPath(forItem: 2, inSection: 0)
        let lastCell = sut.collectionView(sut.collectionView, cellForItemAtIndexPath: lastIndex) as! MotivationDotsCollectionViewCell

        // then
        XCTAssertEqual(firstCell.periodLabel.text, "MONTHS")
        XCTAssertEqual(firstCell.valueLabel.text, "6.8")
        XCTAssertEqual(lastCell.periodLabel.text, "HOURS")
        XCTAssertEqual(lastCell.valueLabel.text, "4866")
    }
    
    func test_cellLayout_ForMoreThanOneYear() {
        // given
        sut.setupWithLifetimeStats(yearStats, shareDelegate: FakeShareDelegate())
        sut.collectionView.reloadData()
        
        // when
        let firstIndex = NSIndexPath(forItem: 0, inSection: 0)
        let firstCell = sut.collectionView(sut.collectionView, cellForItemAtIndexPath: firstIndex) as! MotivationDotsCollectionViewCell
        let lastIndex = NSIndexPath(forItem: 2, inSection: 0)
        let lastCell = sut.collectionView(sut.collectionView, cellForItemAtIndexPath: lastIndex) as! MotivationDotsCollectionViewCell
        
        // then
        XCTAssertEqual(firstCell.periodLabel.text, "YEARS")
        XCTAssertEqual(firstCell.valueLabel.text, "3.4")
        XCTAssertEqual(lastCell.periodLabel.text, "DAYS")
        XCTAssertEqual(lastCell.valueLabel.text, "1216.7")

    }
    
    func test_lastCellForShare() {
        // given
        sut.setupWithLifetimeStats(stats, shareDelegate: FakeShareDelegate())
        sut.collectionView.reloadData()
        
        // when
        let lastIndex = NSIndexPath(forItem: 3, inSection: 0)
        let lastCell = sut.collectionView(sut.collectionView, cellForItemAtIndexPath: lastIndex) as! MotivationShareCollectionViewCell
        
        // then
        XCTAssertEqual(lastCell.topLabel.text, "6.8 MONTHS")
        XCTAssertEqual(lastCell.middleLabel.text, "202.8 DAYS")
        XCTAssertEqual(lastCell.bottomLabel.text, "4866 HOURS")
    }
    
    func test_lastCellForShare_WithYears() {
        // given
        sut.setupWithLifetimeStats(yearStats, shareDelegate: FakeShareDelegate())
        sut.collectionView.reloadData()
        
        // when
        let lastIndex = NSIndexPath(forItem: 3, inSection: 0)
        let lastCell = sut.collectionView(sut.collectionView, cellForItemAtIndexPath: lastIndex) as! MotivationShareCollectionViewCell

        // then
        XCTAssertEqual(lastCell.topLabel.text, "3.4 YEARS")
        XCTAssertEqual(lastCell.middleLabel.text, "40.6 MONTHS")
        XCTAssertEqual(lastCell.bottomLabel.text, "1216.7 DAYS")
    }
}

private struct FakeShareDelegate: ActivityShareDelegate {
    private func shareMotivationImage() {
        
    }
}
