//
//  Duration.swift
//  TimeSlowerDataBase
//
//  Created by Oleksandr Shcherbakov on 9/1/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation

open class Continuation: NSObject {
    
    /// Number of time units - either minutes of hours
    open let value: Int
    
    /// Time Unit type - can be .Minutes or .Hours
    open let period: PeriodData
    
    public required init?(coder aDecoder: NSCoder) {
        self.period = PeriodData(rawValue: aDecoder.decodeInteger(forKey: "period"))!
        self.value = aDecoder.decodeInteger(forKey: "value")
    }
    
    public init(value: Int, period: PeriodData) {
        self.value = value
        self.period = period
    }
    
    open func seconds() -> Double {
        var seconds = Double(value) * 60
        
        if period == .hours {
            seconds = seconds * 60
        }
        
        return seconds
    }
}

extension Continuation: NSCoding {
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(value, forKey: "value")
        aCoder.encode(period.rawValue, forKey: "period")
    }
}
