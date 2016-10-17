//
//  ResultStore.swift
//  TimeSlowerKit
//
//  Created by Alexander Shcherbakov on 9/10/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import CoreData

public struct ResultStore: EntityStore {
    
    public let context: NSManagedObjectContext
    
    public init(withCoreDataStack stack: CoreDataStack) {
        context = stack.managedObjectContext
    }
    
    public func resultsForActivity(activity: ActivityEntity) -> [ResultEntity] {
        let request = NSFetchRequest<ResultEntity>(entityName: ResultEntity.entityName)
        let predicate = NSPredicate(format: "activity.resourceId == %@", activity.resourceId)
        request.predicate = predicate
        
        do {
            let results = try context.fetch(request)
            return results
        } catch {
            return []
        }
    }
}

