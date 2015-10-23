//
//  Timing.swift
//  TimeSlower2
//
//  Created by Aleksander Shcherbakov on 5/22/15.
//  Copyright (c) 2015 1lastDay. All rights reserved.
//

import Foundation
import CoreData

public class Timing: NSManagedObject {

    @NSManaged public var alarmTime: NSDate
    @NSManaged public var duration: NSNumber
    @NSManaged public var finishTime: NSDate
    @NSManaged public var manuallyStarted: NSDate?
    @NSManaged public var startTime: NSDate
    
    /// Time in MINUTES
    @NSManaged public var timeToSave: NSNumber
    @NSManaged public var activity: Activity
}
