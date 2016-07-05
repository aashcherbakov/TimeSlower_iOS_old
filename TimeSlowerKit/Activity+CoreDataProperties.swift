//
//  Activity+CoreDataProperties.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 5/7/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Activity {

    @NSManaged public var basis: NSNumber?
    @NSManaged public var name: String?
    @NSManaged public var type: NSNumber?
    @NSManaged public var days: NSSet
    @NSManaged public var profile: Profile?
    @NSManaged public var results: NSSet?
    @NSManaged public var stats: Stats?
    @NSManaged public var timing: Timing?
    @NSManaged public var notifications: NSNumber?

}
