//
//  Stats.swift
//  TimeSlower2
//
//  Created by Aleksander Shcherbakov on 5/22/15.
//  Copyright (c) 2015 1lastDay. All rights reserved.
//

import Foundation
import CoreData

public class Stats: NSManagedObject, Persistable {

    @NSManaged public var averageSuccess: NSNumber
    @NSManaged public var summDays: NSNumber
    @NSManaged public var summHours: NSNumber
    @NSManaged public var summMonths: NSNumber
    @NSManaged public var summYears: NSNumber
    @NSManaged public var activity: Activity

}
