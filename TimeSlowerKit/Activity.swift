//
//  Activity.swift
//  TimeSlower2
//
//  Created by Aleksander Shcherbakov on 7/3/15.
//  Copyright (c) 2015 1lastDay. All rights reserved.
//

import Foundation
import CoreData

public class Activity: NSManagedObject {
    
    @NSManaged public var basis: NSNumber
    @NSManaged public var days: NSSet
    @NSManaged public var name: String
    @NSManaged public var type: NSNumber
    @NSManaged public var profile: Profile
    @NSManaged public var results: NSSet
    @NSManaged public var stats: Stats
    @NSManaged public var timing: Timing
    
}
