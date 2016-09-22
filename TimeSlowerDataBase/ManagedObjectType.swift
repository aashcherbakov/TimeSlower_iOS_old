//
//  ManagedObjectType.swift
//  TimeSlowerDataBase
//
//  Created by Oleksandr Shcherbakov on 9/1/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import CoreData

public protocol ManagedObjectType: class {
    
    /// Entity name that matches class name, used for fetch requests
    static var entityName: String { get }
    
    /// Property name of an entity that will be used in predicate to fetch specific entity instance.
    static var singleSearchKey: String { get }
    
    /// Default descriptors for sorting result of fetch request
    static var defaultSortDescriptors: [NSSortDescriptor] { get }
    
    /**
     Sets default properties when entity is inserted in NSManagedObjectContext instance
     */
    func setDefaultPropertiesForObject()
    
    /**
     Converts properties passed in configuration object and sets values to entity
     
     - parameter configuration: EntityConfiguration instance
     */
    func updateWithConfiguration(_ configuration: EntityConfiguration)
    
    func setParent(_ parent: ManagedObject?)
}

extension ManagedObjectType {
    
    public static var singleSearchKey: String {
        return "resourceId"
    }
    
    public static var defaultSortDescriptors: [NSSortDescriptor] {
        return []
    }
    
    /// NSFetchRequest instance configured with entity name and default sort descriptors
    public static var sortedFetchRequest: NSFetchRequest<ManagedObject> {
        let request = NSFetchRequest<ManagedObject>(entityName: entityName)
        request.sortDescriptors = defaultSortDescriptors
        return request
    }
    
    /**
     Adds passed predicate instance to NSFetchRequest taken from sortedFetchRequest property.
     
     - parameter predicate: NSPredicate instance
     
     - returns: NSFetchRequest with default sort descriptors and given predicate
     */
    public static func sortedFetchRequestWithPredicate(_ predicate: NSPredicate) -> NSFetchRequest<ManagedObject> {
        let request = sortedFetchRequest
        request.predicate = predicate
        return request
    }
}
