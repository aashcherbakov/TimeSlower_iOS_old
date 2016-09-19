//
//  CoreDataStack.swift
//  TimeSlower2
//
//  Created by Aleksander Shcherbakov on 5/1/15.
//  Copyright (c) 2015 1lastDay. All rights reserved.
//

import Foundation
import CoreData


open class CoreDataStack {
    
   
    
    public init() { }
    
    let sharedAppGroup: String = "group.com.1lastday.timeslower.documents"
    
    open class var sharedInstance: CoreDataStack {
        struct Static {
            static var instance = CoreDataStack()
        }
        
        return Static.instance
    }
    
    open lazy var applicationDocumentsDirectory: URL = {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask) 
        return urls[0]
    }()
    
    open lazy var managedObjectModel: NSManagedObjectModel = {
        let bundle = Bundle(identifier: "oneLastDay.TimeSlowerKit")
        let modelURL = bundle?.url(forResource: "TimeSlower2", withExtension: "momd")
        return NSManagedObjectModel(contentsOf: modelURL!)!
    }()
    
    open lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    open lazy var managedObjectContext: NSManagedObjectContext? = {
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    open func saveContext() {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges {
                do {
                    try moc.save()
                } catch let error1 as NSError {
                    error = error1
                    print("Could not save context: \(error), \(error?.userInfo)")
                    abort()
                }
            }
        }
    }
    
    
    open func fetchProfile() -> Profile? {
        let profileFetch = NSFetchRequest<Profile>(entityName: "Profile")
        let results: [AnyObject]?
        do {
            results = try managedObjectContext?.fetch(profileFetch)
        } catch _ as NSError {
            results = nil
        }
        
        var userProfile: Profile?
        if let profiles = results {
            if profiles.count == 0 {
                return nil
            } else {
                userProfile = profiles[0] as! Profile 
            }
        }
        return userProfile
    }
}
