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
    
    public lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        var error: NSError? = nil
        let sharedContainerURL: NSURL? = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier(self.sharedAppGroup)
        if let sharedConteinerURL = sharedContainerURL {
            let storeURL = sharedContainerURL?.URLByAppendingPathComponent("TimeSlower2")
            var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
            do {
                try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil)
            } catch var error1 as NSError {
                error = error1
                var dict = [String: AnyObject]()
                dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
                dict[NSLocalizedFailureReasonErrorKey] = "There was an error creating or loading the application's saved data."
                dict[NSUnderlyingErrorKey] = error
                error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
                // Replace this with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                print("Unresolved error \(error), \(error!.userInfo)")
                abort()
            } catch {
                fatalError()
            }
            return coordinator
        }
        return nil
    }()
    
    public lazy var managedObjectContext: NSManagedObjectContext? = {
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
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
