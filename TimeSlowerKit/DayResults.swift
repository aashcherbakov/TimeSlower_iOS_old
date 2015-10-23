//
//  DayResults.swift
//  TimeSlower2
//
//  Created by Aleksander Shcherbakov on 7/4/15.
//  Copyright (c) 2015 1lastDay. All rights reserved.
//

import Foundation
import CoreData

public class DayResults: NSManagedObject {
    
    @NSManaged public var raughDate: NSDate
    @NSManaged public var date: String
    
    @NSManaged public var factFinishTime: NSDate
    @NSManaged public var factStartTime: NSDate
    @NSManaged public var factSuccess: NSNumber
    @NSManaged public var factSavedTime: NSNumber?
    @NSManaged public var factDuration: NSNumber

    @NSManaged public var activity: Activity
    
}
