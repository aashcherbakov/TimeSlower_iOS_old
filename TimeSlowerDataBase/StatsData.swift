//
//  Estimates.swift
//  TimeSlowerKit
//
//  Created by Oleksandr Shcherbakov on 9/3/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation

open class EstimationData: NSObject {
    
    open let sumDays: Double
    open let sumHours: Double
    open let sumMonths: Double
    open let sumYears: Double
    
    public required init?(coder aDecoder: NSCoder) {
        self.sumDays = aDecoder.decodeDouble(forKey: "sumDays")
        self.sumHours = aDecoder.decodeDouble(forKey: "sumHours")
        self.sumMonths = aDecoder.decodeDouble(forKey: "sumMonths")
        self.sumYears = aDecoder.decodeDouble(forKey: "sumYears")
    }
    
    public init(days: Double, hours: Double, months: Double, years: Double) {
        sumDays = days
        sumMonths = months
        sumHours = hours
        sumYears = years
    }
}

extension EstimationData: NSCoding {
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(sumDays, forKey: "sumDays")
        aCoder.encode(sumHours, forKey: "sumHours")
        aCoder.encode(sumYears, forKey: "sumYears")
        aCoder.encode(sumMonths, forKey: "sumMonths")
    }
}
