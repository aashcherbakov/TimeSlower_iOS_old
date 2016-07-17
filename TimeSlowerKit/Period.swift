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
    case Days
    case Months
    case Years
    
    /**
     Literal lowercase transript of enum case
     
     - returns: String with literal transcript
     */
    public func description() -> String {
        switch self {
        case .Minutes: return "minutes"
        case .Hours: return "hours"
        case .Days: return "days"
        case .Months: return "months"
        case .Years: return "years"
        }
    }
    
    /**
     3-letter description like "min" or "hrs"
     
     - returns: String with period description
     */
    public func shortDescription() -> String {
        switch self {
        case .Minutes: return "min"
        case .Hours: return "hrs"
        case .Days: return "days"
        case .Months: return "mo"
        case .Years: return "yrs"
        }
    }
}