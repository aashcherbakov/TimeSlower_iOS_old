//
//  AdapterFactory.swift
//  TimeSlowerKit
//
//  Created by Oleksandr Shcherbakov on 9/3/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation
import TimeSlowerDataBase

/**
 *  Factory responsible for creating adapters per specific type (persistable) that will talk to data base directly.
 */
public struct AdapterFactory {
    
    fileprivate let coreDataStack: CoreDataStack
    fileprivate let entityStoreFactory: EntityStoreFactory
    
    public init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
        entityStoreFactory = EntityStoreFactory(withCoreDataStack: coreDataStack)
    }
    
    
    /**
     Creates adapter for given type
     
     - parameter type: Persistable Type
     
     - returns: Adapter that is conforming to DataStoreAdapter protocol
     */
    public func adapter(_ type: Persistable.Type) -> DataStoreAdapter {
        switch type {
        case is Profile.Type:
            return ProfileAdapter(withCoreDataStack: coreDataStack)
            
        case is Activity.Type:
            return ActivityAdapter(withCoreDataStack: coreDataStack)
            
        case is Result.Type:
            return ResultAdapter(withCoreDataStack: coreDataStack)
            
        default:
            fatalError("Unknown type")
        }
    }
}


