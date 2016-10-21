//
//  GenericAdapter.swift
//  TimeSlowerKit
//
//  Created by Oleksandr Shcherbakov on 9/11/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import TimeSlowerDataBase

public protocol GenericAdapter {
    
    associatedtype EntityType: ManagedObject, ManagedObjectType
    associatedtype ParentType: ManagedObject, ManagedObjectType
    
    var creator: EntityStore { get }
    var stack: CoreDataStack { get }
    var converter: PersistableConverter { get }
}

extension GenericAdapter {
    
    public func createObject<T: Persistable>(_ object: T) -> T {
        let entity: EntityType = creator.createEntity(withParent: nil)
        let configuration = converter.configurationFromObject(object)
        let updated: EntityType = creator.updateEntity(entity, configuration: configuration)
        return updated as! T
    }
    
    public func createObject<T: Persistable, U: Persistable>(_ object: T, parent: U) -> T {
        guard let parentEntity: ParentType = creator.entityForKey(parent.searchKey) else {
            fatalError("No parent entity")
        }
        
        let childEntity: EntityType = creator.createEntity(withParent: parentEntity)
        let configuration = converter.configurationFromObject(object)
        let _: EntityType = creator.updateEntity(childEntity, configuration: configuration)
        
        return object
    }
    
    public func retrieveObject<T: Persistable>(_ key: String) -> T? {
        if let entity: EntityType = creator.entityForKey(key) {
            return converter.objectFromEntity(entity, parentObject: nil) as? T
        }
        
        return nil
    }
        
    public func retrieveObjects<T: Persistable>(_ key: String) -> [T]? {
        if let entities: [EntityType] = creator.entitiesForKey(key) {
            return converter.objectsFromEntities(entities) as? [T]
        }
        
        return nil
    }
    
    public func updateObject<T: Persistable>(_ object: Persistable) -> T {
        guard let entity: EntityType = creator.entityForKey(object.searchKey) else {
            fatalError("No object to be updated")
        }
        
        let configuration = converter.configurationFromObject(object)
        let updatedEntity: EntityType = creator.updateEntity(entity, configuration: configuration)
        return converter.objectFromEntity(updatedEntity, parentObject: nil) as! T
    }
    
    public func deleteObject<T: Persistable>(_ object: T) {
        if let entity: EntityType = creator.entityForKey(object.searchKey) {
            creator.deleteEntity(entity)
        }
    }
}
