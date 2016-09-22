//
//  Stats.swift
//  TimeSlowerKit
//
//  Created by Oleksandr Shcherbakov on 9/3/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation

open class StatsData: NSObject {
    
    open let summDays: Double
    open let summHours: Double
    open let summMonths: Double
    open let summYears: Double
    
    public required init?(coder aDecoder: NSCoder) {
        self.summDays = aDecoder.decodeDouble(forKey: "summDays")
        self.summHours = aDecoder.decodeDouble(forKey: "summHours")
        self.summMonths = aDecoder.decodeDouble(forKey: "summMonths")
        self.summYears = aDecoder.decodeDouble(forKey: "summYears")
    }
    
    public init(days: Double, hours: Double, months: Double, years: Double) {
        summDays = days
        summMonths = months
        summHours = hours
        summYears = years
    }
}

extension StatsData: NSCoding {
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(summDays, forKey: "summDays")
        aCoder.encode(summHours, forKey: "summHours")
        aCoder.encode(summYears, forKey: "summYears")
        aCoder.encode(summMonths, forKey: "summMonths")
    }
}
