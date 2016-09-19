//
//  CoreDataBaseTest.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 8/14/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import XCTest
import CoreData
import TimeSlowerKit

class CoreDataBaseTest: XCTestCase {

    var testCoreDataStack: TestCoreDataStack!
    var testContext: NSManagedObjectContext!
    var testProfile: Profile!
    
    /// Creates activity with name "Morning shower" with built in timing
    ///
    /// - Duration: 30 min
    /// - Time to save: 10 min
    /// - Start time: 10:15 AM
    /// - Finish time: 10:45 AM
    var testActivity: Activity!
    var testActivityStats: Stats!
    var testActivityTiming: Timing!

    
    override func setUp() {
        super.setUp()
        // CoreDataStack
        testCoreDataStack = TestCoreDataStack()
        testContext = testCoreDataStack.managedObjectContext
        
        // Creating fake instances
        testProfile = testCoreDataStack.fakeProfile()
        testActivity = testCoreDataStack.fakeActivityWithProfile(testProfile, type: .routine, basis: .daily)
        testCoreDataStack.saveContext()
        
        testActivityTiming = testActivity.timing
        testActivityStats = testActivity.stats
    }
    
    override func tearDown() {
        
        testContext = nil
        testCoreDataStack = nil
        testProfile = nil
        testActivity = nil
        testActivityStats = nil
        testActivityTiming = nil
        
        super.tearDown()
    }

}
