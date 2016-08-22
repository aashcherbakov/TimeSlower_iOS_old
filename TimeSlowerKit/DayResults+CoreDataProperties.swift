//
//  DayResults+CoreDataProperties.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 8/21/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation
import CoreData

public extension DayResults {
    
    /// Fact date of result
    @NSManaged public var raughDate: NSDate
    
    /// String representation of fact date for easy search
    @NSManaged public var date: String
    
    @NSManaged public var factFinishTime: NSDate
    @NSManaged public var factStartTime: NSDate
    @NSManaged public var factSuccess: NSNumber
    @NSManaged public var factSavedTime: NSNumber?
    @NSManaged public var factDuration: NSNumber
    
    @NSManaged public var activity: Activity
    
}