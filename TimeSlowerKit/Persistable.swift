//
//  Persistable.swift
//  TimeSlowerKit
//
//  Created by Oleksandr Shcherbakov on 9/2/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation

/// Protocol that entities are required to confirm in order to be saved.
public protocol Persistable {
   
    /// String that is used to search in data base. By default - resource id.
    var searchKey: String { get }
    
    /// Unique identifier for persisted object.
    var resourceId: String { get }
    
}

// MARK: - Default implementation

extension Persistable {

    public var searchKey: String {
        return resourceId
    }

}

