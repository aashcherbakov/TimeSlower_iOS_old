//
//  EntityStoreFactory.swift
//  TimeSlowerKit
//
//  Created by Alexander Shcherbakov on 9/6/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import CoreData
import TimeSlowerDataBase

public struct EntityStoreFactory {
    fileprivate let stack: CoreDataStack
    
    public init(withCoreDataStack stack: CoreDataStack) {
        self.stack = stack
    }
    
    public func EntityStoreForType(_ type: Persistable.Type) -> EntityStore {
        switch type {
        case is Profile.Type:
            return ProfileStore(withCoreDataStack: stack)
        case is Activity.Type:
            return ActivityStore(withCoreDataStack: stack)
        case is Result.Type:
            return ResultStore(withCoreDataStack: stack)
        default:
            fatalError("Unknown type: \(type)")
        }
    }
}
