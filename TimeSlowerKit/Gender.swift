//
//  Gender.swift
//  TimeSlowerKit
//
//  Created by Oleksandr Shcherbakov on 9/2/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation

/**
 Enum to describe gender of user 
 */
public enum Gender: Int {
    case male = 0
    case female = 1
    
    func description() -> String {
        switch self {
        case .male: return "Male"
        case .female: return "Female"
        }
    }
}
