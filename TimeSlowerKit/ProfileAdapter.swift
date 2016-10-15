//
//  ProfileAdapter.swift
//  TimeSlowerKit
//
//  Created by Oleksandr Shcherbakov on 9/2/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation
import TimeSlowerDataBase
import UIKit

/**
 *  Adapter used to store/retrieve/update Profile information in data base.
 *  Only DataStore knows about adapters, their access remains internal so they can't be used outside of TimeSlowerKit
 */
internal struct ProfileAdapter: GenericAdapter, DataStoreAdapter {
    
    typealias EntityType = ProfileEntity
    typealias ParentType = ProfileEntity
    
    let creator: EntityStore
    let stack: CoreDataStack
    let converter: PersistableConverter
    
    init(withCoreDataStack stack: CoreDataStack) {
        self.stack = stack
        self.creator = ProfileStore(withCoreDataStack: stack)
        self.converter = ProfileConverter()
    }
}

