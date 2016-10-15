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
}

