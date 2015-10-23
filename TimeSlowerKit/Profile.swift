//
//  Profile.swift
//  TimeSlower2
//
//  Created by Aleksander Shcherbakov on 5/22/15.
//  Copyright (c) 2015 1lastDay. All rights reserved.
//

import Foundation
import CoreData

public class Profile: NSManagedObject {

    @NSManaged public var birthday: NSDate
    @NSManaged public var country: String
    @NSManaged public var dateOfDeath: NSDate
    @NSManaged public var gender: NSNumber
    @NSManaged public var name: String
    @NSManaged public var photo: NSData
    @NSManaged public var activities: NSSet

}
