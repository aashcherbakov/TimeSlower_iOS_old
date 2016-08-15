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
        testActivity = testCoreDataStack.fakeActivityWithProfile(testProfile, type: .Routine, basis: .Daily)
        testCoreDataStack.saveContext()
        
        testActivityTiming = testActivity.timing
        testActivityStats = testActivity.stats
    }
    
    override func tearDown() {
        testCoreDataStack = nil
        super.tearDown()
    }

}
