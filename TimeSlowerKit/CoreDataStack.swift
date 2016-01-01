//
//  CoreDataStack.swift
//  TimeSlower2
//
//  Created by Aleksander Shcherbakov on 5/1/15.
//  Copyright (c) 2015 1lastDay. All rights reserved.
//

import Foundation
import CoreData


public class CoreDataStack {

    let sharedAppGroup: String = "group.com.1lastday.timeslower.documents"
    
    public class var sharedInstance: CoreDataStack {
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : CoreDataStack? = nil
        }
        
        dispatch_once(&Static.onceToken) {
            Static.instance = CoreDataStack()
        }
        return Static.instance!
    }
    
    public lazy var applicationDocumentsDirectory: NSURL = {
        let fileManager = NSFileManager.defaultManager()
        let urls = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask) 
        return urls[0]
    }()
    
    public lazy var managedObjectModel: NSManagedObjectModel = {
        let bundle = NSBundle(identifier: "oneLastDay.TimeSlowerKit")
        let modelURL = bundle?.URLForResource("TimeSlower2", withExtension: "momd")
        return NSManagedObjectModel(contentsOfURL: modelURL!)!
    }()
    
    public lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    public lazy var managedObjectContext: NSManagedObjectContext? = {
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    public func saveContext() {
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
    
    
    public func fetchProfile() -> Profile? {
        let profileFetch = NSFetchRequest(entityName: "Profile")
        let results: [AnyObject]?
        do {
            results = try managedObjectContext?.executeFetchRequest(profileFetch)
        } catch _ as NSError {
            results = nil
        }
        
        var userProfile: Profile?
        if let profiles = results {
            if profiles.count == 0 {
                return nil
            } else {
                userProfile = profiles[0] as? Profile
            }
        }
        return userProfile
    }
}
