//
//  ManagedObject.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 7/10/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation
import CoreData

open class ManagedObject: NSManagedObject { }

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
    public func willAccessValueForKey(_ key: Keys) {
        willAccessValue(forKey: key.rawValue)
    }
    
    public func didAccessValueForKey(_ key: Keys) {
        didAccessValue(forKey: key.rawValue)
    }
    
    public func willChangeValueForKey(_ key: Keys) {
        (self as ManagedObject).willChangeValue(forKey: key.rawValue)
    }
    
    public func didChangeValueForKey(_ key: Keys) {
        (self as ManagedObject).didChangeValue(forKey: key.rawValue)
    }
    
    public func valueForKey(_ key: Keys) -> AnyObject? {
        return (self as ManagedObject).value(forKey: key.rawValue) as AnyObject?
    }
    
    public func mutableSetValueForKey(_ key: Keys) -> NSMutableSet {
        return mutableSetValue(forKey: key.rawValue)
    }
    
    public func changedValueForKey(_ key: Keys) -> AnyObject? {
        return changedValues()[key.rawValue] as AnyObject?
    }
    
    public func committedValueForKey(_ key: Keys) -> AnyObject? {
        return committedValues(forKeys: [key.rawValue])[key.rawValue] as AnyObject?
    }
}
