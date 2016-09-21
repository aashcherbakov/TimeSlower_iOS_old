//
//  ResultAdapter.swift
//  TimeSlowerKit
//
//  Created by Alexander Shcherbakov on 9/10/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import TimeSlowerDataBase


public struct ResultAdapter: GenericAdapter, DataStoreAdapter {
    
    public typealias EntityType = ResultEntity
    public typealias ParentType = ActivityEntity
    
    public let creator: EntityStore
    public let stack: CoreDataStack
    public let converter: PersistableConverter
    
    init(withCoreDataStack stack: CoreDataStack) {
        self.stack = stack
        self.creator = ResultStore(withCoreDataStack: stack)
        self.converter = ResultConverter()
    }
}


