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
    private let stack: CoreDataStack
    
    public init(withCoreDataStack stack: CoreDataStack) {
        context = stack.managedObjectContext
        self.stack = stack
    }
    
    public func allActivities() -> [ActivityEntity] {
        let request = NSFetchRequest<ActivityEntity>(entityName: ActivityEntity.entityName)
        let activities = try! context.fetch(request)
        return activities 
    }
    
    public func activities(forDate date: Date?, ofType type: ActivityEntity.ActivityType) -> [ActivityEntity] {
        let activities = allActivities()
        
        guard let date = date else {
            return activities
        }
        
        let day = Day.createFromDate(date)
        return activities.filter { (entity) -> Bool in
            return entity.type.intValue == type.rawValue && entity.days.contains(day)
        }
    }
    
    public func deleteEntity<T: ManagedObjectType>(_ entity: T) {
        guard let object = entity as? ActivityEntity else {
            fatalError("Passed entity is not a NSManagedObject subclass")
        }
        
        removeResultsForActivity(activity: object)
        context.delete(object)
        context.saveOrRollback()
    }
    
    private func removeResultsForActivity(activity: ActivityEntity) {
        let resultsStore = ResultStore(withCoreDataStack: stack)
        let results = resultsStore.resultsForActivity(activity: activity)
        for result in results {
            context.delete(result)
        }
    }
}
