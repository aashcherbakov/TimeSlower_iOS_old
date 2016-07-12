//
//  Period.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 7/10/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation

/**
 Describes variants of time period: minutes and hours
 */
public enum Period: Int {
    case Minutes
    case Hours
    
    /**
     Literal lowercase transript of enum case
     
     - returns: String with literal transcript
     */
    public func description() -> String {
        switch self {
        case .Minutes: return "minutes"
        case .Hours: return "hours"
        }
    }
}