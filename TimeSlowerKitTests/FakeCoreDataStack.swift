//
//  FakeCoreDataStack.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 9/21/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation

import Foundation
import CoreData
import TimeSlowerDataBase

open class FakeCoreDataStack: CoreDataStack {
    
    required public override init() {
        super.init()
        self.persistentStoreCoordinator = {
            
            let psc = NSPersistentStoreCoordinator(
                managedObjectModel: self.managedObjectModel)
            
            do {
                try psc.addPersistentStore(
                    ofType: NSInMemoryStoreType, configurationName: nil,
                    at: nil, options: nil)
            } catch {
                fatalError()
            }
            
            return psc
        }()
    }
}
