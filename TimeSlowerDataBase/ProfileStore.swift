//
//  ProfileStore.swift
//  TimeSlowerDataBase
//
//  Created by Oleksandr Shcherbakov on 9/1/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import CoreData
import UIKit

public struct ProfileStore: EntityStore {
    
    public let context: NSManagedObjectContext
    
    public init(withCoreDataStack stack: CoreDataStack) {
        context = stack.managedObjectContext
    }
    
    /**
     Overrides default protocol implementation.
     Makes sure there is no profile created yet, and only then creates one.
     Workaround for singleton-like core data storage
     
     - returns: ProfileEntity
     */
    public func createEntity<T : ManagedObject>() -> T {
        if let profile: ProfileEntity = fetchEntity() {
            return profile as! T
        } else {
            return insertProfileInContext(context) as! T
        }
    }
    
    public func entityForKey<T : ManagedObjectType>(_ key: String) -> T? {
        return fetchEntity() as? T
    }

    
    // MARK: - Private Functions
    
    fileprivate func insertProfileInContext(_ context: NSManagedObjectContext) -> ProfileEntity {
        let profile: ProfileEntity = context.insertObject()
        profile.setDefaultPropertiesForObject()
        context.saveOrRollback()
        return profile
    }
    
    fileprivate func fetchEntity<T: ManagedObject>() -> T? {
        var profile: ProfileEntity!
        do {
            profile = try context.fetch(ProfileEntity.sortedFetchRequest).first as? ProfileEntity
        } catch {
            fatalError("Could not fetch profile")
        }
        return profile as? T
    }
    
}
