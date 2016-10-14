//
//  ManagedObject.swift
//  TimeSlowerDataBase
//
//  Created by Oleksandr Shcherbakov on 9/1/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import CoreData

open class ManagedObject: NSManagedObject, NSCopying {
    
    public func copy(with zone: NSZone? = nil) -> Any {
        return type(of:self).init(context: self.managedObjectContext!)
    }
}

