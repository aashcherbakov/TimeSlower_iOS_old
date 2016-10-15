//
//  Persistable.swift
//  TimeSlowerKit
//
//  Created by Oleksandr Shcherbakov on 9/2/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation

public protocol Persistable {
   
    var searchKey: String { get }
    var resourceId: String { get }
    
}

extension Persistable {
    public var searchKey: String {
        return resourceId
    }
}

