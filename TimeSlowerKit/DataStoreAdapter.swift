//
//  DataStoreAdapter.swift
//  TimeSlowerKit
//
//  Created by Oleksandr Shcherbakov on 9/3/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation
import TimeSlowerDataBase

/**
 *  Used to bypass generic constraints of using GenericAdapter and create a factory for adapters.
 *  Each adapter implements both protocols: GenericAdapter with default implementation works with 
 *  associated types and allows effectively create, retrieve and delete objects.
 *
 *  DataStoreAdapter requires methods that are implemented in GenericAdapter implementation
 *  and serves just as a common interface for Factory.
 */
public protocol DataStoreAdapter {
    
    func createObject<T: Persistable>(_ object: T)
    
    func createObject<T: Persistable, U: Persistable>(_ object: T, parent: U) -> T
    
    func retrieveObject<T: Persistable>(_ key: String) -> T?
    
    func updateObject<T: Persistable>(_ object: Persistable) -> T
    
    func deleteObject<T: Persistable>(_ object: T)
    
}
