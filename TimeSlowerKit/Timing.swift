//
//  Timing.swift
//  TimeSlower2
//
//  Created by Aleksander Shcherbakov on 5/22/15.
//  Copyright (c) 2015 1lastDay. All rights reserved.
//

import Foundation
import CoreData

public class Timing: ManagedObject {

    @NSManaged public var alarmTime: NSDate
    @NSManaged public var duration: ActivityDuration
    @NSManaged public var finishTime: NSDate
    @NSManaged public var manuallyStarted: NSDate?
    @NSManaged public var startTime: NSDate
    
    /// Time in MINUTES
    @NSManaged public var timeToSave: NSNumber
    @NSManaged public var activity: Activity
}

extension Timing: ManagedObjectType {
    public static var entityName: String {
        return "Timing"
    }
    
    public static var defaultSortDescriptors: [NSSortDescriptor] {
        return []
    }
}