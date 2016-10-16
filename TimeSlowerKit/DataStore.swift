//
//  DataStore.swift
//  TimeSlowerKit
//
//  Created by Oleksandr Shcherbakov on 9/1/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation
import UIKit
import TimeSlowerDataBase

public struct DataStore {
    
    fileprivate let coreDataStack: CoreDataStack
    fileprivate let adapterFactory: AdapterFactory

    public init(withCoreDataStack stack: CoreDataStack = CoreDataStack.sharedInstance) {
        coreDataStack = stack
        adapterFactory = AdapterFactory(coreDataStack: stack)
    }
    
    /**
     Creating entity in data base and returns persistable object
     
     - returns: Persistable object translated from entity
     */
    public func create<T: Persistable, U: Persistable>(_ object: T, withParent parent: U) {
        let adapter = adapterFactory.adapter(T.self)
        adapter.createObject(object, parent: parent)
    }
    
    public func create<T: Persistable>(_ object: T) {
        let adapter = adapterFactory.adapter(T.self)
        adapter.createObject(object)
    }
    
    public func update<T: Persistable>(_ object: T) -> T {
        let adapter = adapterFactory.adapter(T.self)
        let updated: T = adapter.updateObject(object)
        return updated
    }
    
    public func delete<T: Persistable>(_ object: T) {
        let adapter = adapterFactory.adapter(T.self)
        adapter.deleteObject(object)
    }
    
    public func retrieve<T: Persistable>(_ key: String) -> T? {
        let adapter = adapterFactory.adapter(T.self)
        return adapter.retrieveObject(key)
    }
    
    public func retrieveAll<T: Persistable>(_ key: String) -> [T]? {
        let adapter = adapterFactory.adapter(T.self)
        return adapter.retrieveObjects(key)
    }
    
    public func activities(forDate date: Date?, type: ActivityType) -> [Activity] {
        let adapter = ActivityAdapter(withCoreDataStack: coreDataStack)
        return adapter.activities(forDate: date, type: type)
    }

}
