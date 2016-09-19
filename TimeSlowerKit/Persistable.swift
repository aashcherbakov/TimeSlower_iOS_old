//
//  Persistable.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 4/29/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation
import CoreData

/// Protocol that extends NSManagedObject to wrap some convenience functions
public protocol Persistable: class { }

public extension Persistable {
    /// Wrapper for save() function of NSManagedObjectContext called that trows error in default implementation
    static func saveContext(_ context: NSManagedObjectContext?) {
        do {
            try context?.save()
        } catch let error as NSError {
            print("Saving error: \(error.localizedDescription)")
        }
    }
}
