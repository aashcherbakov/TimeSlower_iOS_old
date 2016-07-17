//
//  Duration.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 7/9/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation

/// Object that encapsulates duration value and period description
public class ActivityDuration: NSObject {
    /// Number of time units - either minutes of hours
    public let value: Int
    
    /// Time Unit type - can be .Minutes or .Hours
    public let period: Period
    
    public required init?(coder aDecoder: NSCoder) {
        self.period = Period(rawValue: aDecoder.decodeIntegerForKey("period"))!
        self.value = aDecoder.decodeIntegerForKey("value")
    }
    
    public init(value: Int, period: Period) {
        self.value = value
        self.period = period
    }
    
    /**
     Returns equivalent of value in seconds
     
     - returns: Double for seconds in value
     */
    public func seconds() -> Double {
        var seconds = Double(value) * 60
        
        if period == .Hours {
            seconds = seconds * 60
        }
        
        return seconds
    }
    
    /**
     Returns equivalent of value in minutes
     
     - returns: Int for number of minutes in value
     */
    public func minutes() -> Int {
        switch period {
        case .Hours: return value * 60
        case .Minutes: return value
        default: return 0
        }
    }
    
    /**
     Returns equivalent of value in hours
     
     - returns: Int for number of hours in value
     */
    public func hours() -> Int {
        switch period {
        case .Hours: return value
        case .Minutes: return value / 60
        default: return 0
        }
    }
    
    /**
     Transforms value and period into string.
     
     - returns: String as "34 min" or "1 hr"
     */
    public func shortDescription() -> String {
        return "\(value) \(period.shortDescription())"
    }
}

extension ActivityDuration: NSCoding {
    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInteger(value, forKey: "value")
        aCoder.encodeInteger(period.rawValue, forKey: "period")
    }
}

