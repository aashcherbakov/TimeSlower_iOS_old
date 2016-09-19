//
//  Stats.swift
//  TimeSlower2
//
//  Created by Aleksander Shcherbakov on 5/22/15.
//  Copyright (c) 2015 1lastDay. All rights reserved.
//

import Foundation
import CoreData

open class Stats: NSManagedObject, Persistable {

    @NSManaged open var averageSuccess: NSNumber
    @NSManaged open var summDays: NSNumber
    @NSManaged open var summHours: NSNumber
    @NSManaged open var summMonths: NSNumber
    @NSManaged open var summYears: NSNumber
    @NSManaged open var activity: Activity

}
