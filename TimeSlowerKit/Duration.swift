//
//  Duration.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 7/9/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation

public class ActivityDuration: NSObject {
    public let value: Int
    public let period: Period
    
    public required init?(coder aDecoder: NSCoder) {
        self.period = Period(rawValue: aDecoder.decodeIntegerForKey("period"))!
        self.value = aDecoder.decodeIntegerForKey("value")
    }
    
    public init(value: Int, period: Period) {
        self.value = value
        self.period = period
    }
    
    public func seconds() -> Double {
        var seconds = Double(value) * 60
        
        if period == .Hours {
            seconds = seconds * 60
        }
        
        return seconds
    }
    
    public func minutes() -> Int {
        switch period {
        case .Hours: return value * 60
        case .Minutes: return value
        }
    }
    
    public func hours() -> Int {
        switch period {
        case .Hours: return value
        case .Minutes: return value / 60
        }
    }
}

extension ActivityDuration: NSCoding {
    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInteger(value, forKey: "value")
        aCoder.encodeInteger(period.rawValue, forKey: "period")
    }
}

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