//
//  ActivityAdapter.swift
//  TimeSlowerKit
//
//  Created by Oleksandr Shcherbakov on 9/3/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation
import TimeSlowerDataBase

internal struct ActivityAdapter: GenericAdapter, DataStoreAdapter {

    typealias EntityType = ActivityEntity
    typealias ParentType = ProfileEntity
    
    let creator: EntityStore
    let stack: CoreDataStack
    let converter: PersistableConverter
    
    init(withCoreDataStack stack: CoreDataStack) {
        self.stack = stack
        self.creator = ActivityStore(withCoreDataStack: stack)
        self.converter = ActivityConverter()
    }
    

    public func activities(forDate date: Date?, type: ActivityType) -> [Activity] {
        
        return (creator as! ActivityStore)
            .activities(forDate: date, ofType: ActivityEntity.ActivityType(rawValue: type.rawValue)!)
            .map { (entity) -> Activity in
                (converter as! ActivityConverter).objectFromEntity(entity, parentObject: nil) as! Activity
        }
    }
}



