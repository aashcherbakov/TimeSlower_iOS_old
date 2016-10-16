//
//  Result.swift
//  TimeSlowerDataBase
//
//  Created by Oleksandr Shcherbakov on 9/1/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation
import CoreData


open class ResultEntity: ManagedObject {

    @NSManaged open var stringDate: String
    @NSManaged open var duration: NSNumber
    @NSManaged open var finishTime: Date
    @NSManaged open var savedTime: NSNumber?
    @NSManaged open var startTime: Date
    @NSManaged open var success: NSNumber
    @NSManaged open var date: Date
    @NSManaged open var activity: ActivityEntity
    @NSManaged open var resourceId: String
}

extension ResultEntity: ManagedObjectType {
    public static var entityName: String {
        return self.className
    }
    
    public static var singleSearchKey: String {
        return "stringDate"
    }
    
    public func setDefaultPropertiesForObject() {
        startTime = Date()
        finishTime = Date()
        duration = 0
        savedTime = 0
        success = 0
        date = Date()
        stringDate = DefaultDateFormatter.shortDateNoTimeFromatter.string(from: finishTime)
        resourceId = ""
    }
    
    public func updateWithConfiguration(_ configuration: EntityConfiguration) {
        guard let configuration = configuration as? ResultConfiguration else {
            fatalError("Wrong configuration")
        }
        
        stringDate = configuration.stringDate
        duration = NSNumber(value: configuration.duration)
        finishTime = configuration.finishTime as Date
        savedTime = configuration.savedTime as NSNumber?
        startTime = configuration.startTime as Date
        success = NSNumber(value: configuration.success)
        date = configuration.date as Date
        
        if resourceId == "" {
            resourceId = configuration.resourceId
        }
    }
    
    public func setParent(_ parent: ManagedObject?) {
        guard let activity = parent as? ActivityEntity else {
            fatalError("Parent should be ActivityEntity")
        }
        
        activity.results.adding(self)
        
        // TODO: update average success for activity
        self.activity = activity
    }
}
