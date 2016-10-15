//
//  BaseCoreDataTest.swift
//  TimeSlowerKit
//
//  Created by Alexander Shcherbakov on 9/10/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import XCTest
import CoreData
import TimeSlowerDataBase

class BaseDataStoreTest: XCTestCase {
    
    /// Format: "8/29/1990"
    var shortDateFormatter: DateFormatter!
    
    /// Format: "8/29/1990, 10:30 AM"
    var shortTimeFormatter: DateFormatter!
    
    /// CoreDataStack with InMemory storage
    var fakeCoreDataStack: CoreDataStack!
    
    override func setUp() {
        super.setUp()
        fakeCoreDataStack = FakeCoreDataStack()
        shortDateFormatter = DefaultDateFormatter.shortDateNoTimeFromatter
        shortTimeFormatter = DefaultDateFormatter.shortDateAndTimeFormatter
    }
    
    override func tearDown() {
        fakeCoreDataStack = nil
        shortDateFormatter = nil
        shortTimeFormatter = nil
        super.tearDown()
    }
    
}
