//
//  ActivityStore.swift
//  TimeSlowerKit
//
//  Created by Oleksandr Shcherbakov on 9/3/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation
import CoreData


public struct ActivityStore: EntityStore {
    public let context: NSManagedObjectContext
    
    public init(withCoreDataStack stack: CoreDataStack) {
        context = stack.managedObjectContext
    }
    
    public func allActivities() -> [ActivityEntity] {
        let request = NSFetchRequest<ActivityEntity>(entityName: ActivityEntity.entityName)
        let activities = try! context.fetch(request)
        return activities 
    }
    
    public func activities(forDate date: Date, ofType type: ActivityEntity.ActivityType) -> [ActivityEntity] {
        let activities = allActivities()
        
        let day = Day.createFromDate(date)
        
        return activities.filter { (entity) -> Bool in
            return entity.type.intValue == type.rawValue && entity.days.contains(day)
        }
    }
}
