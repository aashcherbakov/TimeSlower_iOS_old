//
//  NSManagedObjectContext+Extension.swift
//  TimeSlowerDataBase
//
//  Created by Oleksandr Shcherbakov on 9/1/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import CoreData

extension NSManagedObjectContext {
    
    /**
     Inserts object that conforms to ManagedObjectType protocol into context
     
     - returns: ManagedObject instance
     */
    public func insertObject<T: ManagedObject>() -> T where T: ManagedObjectType {
        guard let object = NSEntityDescription.insertNewObject(forEntityName: T.entityName, into: self) as? T else {
            fatalError("Wrong object type")
        }
        
        return object
    }
    
    /**
     Helper method to catch exception when saving context didn't work out
     
     - returns: True if save() worked
     */
    public func saveOrRollback() {
        do {
            try save()
        } catch {
            rollback()
        }
    }
    
    /**
     Helper method that allows to encapsulate changes to contest with saving / rollback to the context
     
     - parameter block: Block to be executed before saving. Insert/change entities here
     */
    public func performChanges(_ block: @escaping () -> ()) {
        perform { [unowned self] in
            block()
            self.saveOrRollback()
        }
    }
}
