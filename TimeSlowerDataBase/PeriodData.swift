//
//  Period.swift
//  TimeSlowerKit
//
//  Created by Oleksandr Shcherbakov on 9/2/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation

/**
 Describes variants of time period: minutes and hours
 */
public enum PeriodData: Int {
    case minutes
    case hours
    case days
    case months
    case years
    
    /**
     Literal lowercase transript of enum case
     
     - returns: String with literal transcript
     */
    public func description() -> String {
        switch self {
        case .minutes: return "minutes"
        case .hours: return "hours"
        case .days: return "days"
        case .months: return "months"
        case .years: return "years"
        }
    }
    
    /**
     3-letter description like "min" or "hrs"
     
     - returns: String with period description
     */
    public func shortDescription() -> String {
        switch self {
        case .minutes: return "min"
        case .hours: return "hrs"
        case .days: return "days"
        case .months: return "mo"
        case .years: return "yrs"
        }
    }

}
