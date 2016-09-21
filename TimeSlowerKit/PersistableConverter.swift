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
    
    func configurationFromObject(_ object: Persistable) -> EntityConfiguration
    
}
