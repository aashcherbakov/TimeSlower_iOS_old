//
//  EntityStore.swift
//  TimeSlowerKit
//
//  Created by Oleksandr Shcherbakov on 9/5/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import CoreData

public protocol EntityConfiguration { }

public protocol EntityStore {
    
    init(withCoreDataStack stack: CoreDataStack)
    
    /// NSManagedObjectContext instance in which entity should be stored
    var context: NSManagedObjectContext { get }
    
    /**
     Inserts entity in managed object context and sets up default values

     - warning: Has default implementation
     - returns: ManagedObject type
     */
    func createEntity<T: ManagedObject>(withParent parent: ManagedObject?) -> T where T: ManagedObjectType
    
    /**
     Fetches entity for specified single search key. Key is different for every entity
     and is defined in ManagedObjectType extension.
     
     - warning: Has default implementation
     - parameter key: String that should be a value for managed objects .singleSearchKey. Ex: name = Shower for activity
     
     - returns: ManagedObject instance if there is one in managed object context
     */
    func entityForKey<T: ManagedObjectType>(_ key: String) -> T?
    
    func entitiesForKey<T: ManagedObject>(_ key: String) -> [T]? where T: ManagedObjectType
    
    /**
     Updates given entity with provided entity configuration. Has default implementation.
     
     - warning: Has default implementation
     - parameter entity:        ManagedObject instance
     - parameter configuration: EntityConfiguration instance
     
     - returns: ManagedObject instance with updated properties
     */
    func updateEntity<T: ManagedObjectType>(_ entity: T, configuration: EntityConfiguration) -> T
    
    func deleteEntity<T: ManagedObjectType>(_ entity: T)
    
}

public extension EntityStore {
    
    public func createEntity<T: ManagedObject>(withParent parent: ManagedObject? = nil) -> T where T: ManagedObjectType {
        let entity: T = context.insertObject()
        entity.setDefaultPropertiesForObject()
        entity.setParent(parent)
        context.saveOrRollback()
        return entity
    }
    
    public func entityForKey<T: ManagedObjectType>(_ key: String) -> T? {
        let predicate = NSPredicate(format: "\(T.singleSearchKey) == %@", key)
        let request = T.sortedFetchRequestWithPredicate(predicate)
        
        do {
            let entity = try context.fetch(request).first as? T
            return entity
        } catch {
            return nil
        }
    }
    
    public func entitiesForKey<T: ManagedObject>(_ key: String) -> [T]? where T: ManagedObjectType {
        let predicate = NSPredicate(format: "\(T.singleSearchKey) == %@", key)
        let request = T.sortedFetchRequestWithPredicate(predicate)
        
        do {
            let entities = try context.fetch(request) as? [T]
            return entities
        } catch {
            return nil
        }
    }

    
    public func updateEntity<T: ManagedObjectType>(_ entity: T, configuration: EntityConfiguration) -> T {
        entity.updateWithConfiguration(configuration)
        context.saveOrRollback()
        return entity
    }
    
    public func deleteEntity<T: ManagedObjectType>(_ entity: T) {
        guard let object = entity as? NSManagedObject else {
            fatalError("Passed entity is not a NSManagedObject subclass")
        }
        
        context.delete(object)
        context.saveOrRollback()
    }
}
