//
//  ManagedObject.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 7/10/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation
import CoreData

public class ManagedObject: NSManagedObject { }

public protocol ManagedObjectType: class {
    static var entityName: String { get }
    static var defaultSortDescriptors: [NSSortDescriptor] { get }
    var managedObjectContext: NSManagedObjectContext? { get }
}

/**
 *  Protocol that is used to save Transformable types in Core Data
 */
public protocol KeyCodable {
    associatedtype Keys: RawRepresentable
}


extension KeyCodable where Self: ManagedObject, Keys.RawValue == String {
    public func willAccessValueForKey(key: Keys) {
        willAccessValueForKey(key.rawValue)
    }
    
    public func didAccessValueForKey(key: Keys) {
        didAccessValueForKey(key.rawValue)
    }
    
    public func willChangeValueForKey(key: Keys) {
        (self as ManagedObject).willChangeValueForKey(key.rawValue)
    }
    
    public func didChangeValueForKey(key: Keys) {
        (self as ManagedObject).didChangeValueForKey(key.rawValue)
    }
    
    public func valueForKey(key: Keys) -> AnyObject? {
        return (self as ManagedObject).valueForKey(key.rawValue)
    }
    
    public func mutableSetValueForKey(key: Keys) -> NSMutableSet {
        return mutableSetValueForKey(key.rawValue)
    }
    
    public func changedValueForKey(key: Keys) -> AnyObject? {
        return changedValues()[key.rawValue]
    }
    
    public func committedValueForKey(key: Keys) -> AnyObject? {
        return committedValuesForKeys([key.rawValue])[key.rawValue]
    }
}