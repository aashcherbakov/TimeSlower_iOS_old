//
//  CoreDataStack.swift
//  TimeSlowerDataBase
//
//  Created by Oleksandr Shcherbakov on 9/1/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation
import CoreData


open class CoreDataStack {
    
    public init() { }
    
    let sharedAppGroup: String = "group.com.1lastday.timeslower.documents"

    open class var sharedInstance: CoreDataStack {
        struct Static {
            static let instance = CoreDataStack()
        }
        
        return Static.instance
    }

    
    open lazy var managedObjectContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    open lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        try! persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: self.applicationDocumentsDirectory, options: nil)
        return persistentStoreCoordinator
    }()
    
    // MARK: - Private 
    
    fileprivate lazy var applicationDocumentsDirectory: URL = {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[0].appendingPathComponent("TimeSlower.timeslower")
    }()
    
    open lazy var managedObjectModel: NSManagedObjectModel = {
        let bundles = [Bundle(for: ProfileEntity.self)]
        guard let model = NSManagedObjectModel.mergedModel(from: bundles) else {
            fatalError("Model not found")
        }
        
        return model
    }()
}
