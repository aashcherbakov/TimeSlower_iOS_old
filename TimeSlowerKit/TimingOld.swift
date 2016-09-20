////
////  Timing.swift
////  TimeSlower2
////
////  Created by Aleksander Shcherbakov on 5/22/15.
////  Copyright (c) 2015 1lastDay. All rights reserved.
////
//
//import Foundation
//import CoreData
//
//open class Timing: ManagedObject {
//
//    @NSManaged open var alarmTime: Date
//    @NSManaged open var duration: ActivityDuration
//    @NSManaged open var finishTime: Date
//    @NSManaged open var manuallyStarted: Date?
//    @NSManaged open var startTime: Date
//    
//    /// Time in MINUTES
//    @NSManaged open var timeToSave: NSNumber
//    @NSManaged open var activity: Activity
//}
//
//extension Timing: ManagedObjectType {
//    public static var entityName: String {
//        return "Timing"
//    }
//    
//    public static var defaultSortDescriptors: [NSSortDescriptor] {
//        return []
//    }
//}
