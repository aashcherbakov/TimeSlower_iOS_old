//
//  RouterTests.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 12/17/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import XCTest
@testable import TimeSlower
@testable import TimeSlowerKit

class RouterTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_controllerForDestination() {
        let router = Router()
        let profile = Profile(name: "", country: "", dateOfBirth: Date(), gender: .female, maxAge: 11, photo: nil)
        let controller = router.controller(for: .editActivity(profile: profile, activity: nil))
        XCTAssertNotNil(controller)
        XCTAssertTrue(controller is EditActivityVC, "It should be EditActivityVC")
    }

}
