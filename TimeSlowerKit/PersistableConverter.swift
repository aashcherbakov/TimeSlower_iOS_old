//
//  PersistableConverter.swift
//  TimeSlowerKit
//
//  Created by Oleksandr Shcherbakov on 9/11/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import TimeSlowerDataBase

public protocol PersistableConverter {
    
    func objectFromEntity(_ entity: ManagedObject, parentObject: Persistable?) -> Persistable
    
    func objectsFromEntities(_ entities: [ManagedObject]) -> [Persistable]
    
    func configurationFromObject(_ object: Persistable) -> EntityConfiguration
    
}

public extension PersistableConverter {
    public func objectsFromEntities(_ entities: [ManagedObject]) -> [Persistable] {
        if entities.count > 0 {
            if let entity = entities.first {
                let object = objectFromEntity(entity, parentObject: nil)
                return [object]
            }
        }
        
        return []
    }
}
