////
////  Duration.swift
////  TimeSlower
////
////  Created by Oleksandr Shcherbakov on 7/9/16.
////  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
////
//
//import Foundation
//
///// Object that encapsulates duration value and period description
//open class Endurance: NSObject {
//    /// Number of time units - either minutes of hours
//    open let value: Int
//    
//    /// Time Unit type - can be .Minutes or .Hours
//    open let period: Period
//    
//    public required init?(coder aDecoder: NSCoder) {
//        self.period = Period(rawValue: aDecoder.decodeInteger(forKey: "period"))!
//        self.value = aDecoder.decodeInteger(forKey: "value")
//    }
//    
//    public init(value: Int, period: Period) {
//        self.value = value
//        self.period = period
//    }
//    
//    /**
//     Returns equivalent of value in seconds
//     
//     - returns: Double for seconds in value
//     */
//    open func seconds() -> Double {
//        var seconds = Double(value) * 60
//        
//        if period == .hours {
//            seconds = seconds * 60
//        }
//        
//        return seconds
//    }
//    
//    /**
//     Returns equivalent of value in minutes
//     
//     - returns: Int for number of minutes in value
//     */
//    open func minutes() -> Int {
//        switch period {
//        case .hours: return value * 60
//        case .minutes: return value
//        default: return 0
//        }
//    }
//    
//    /**
//     Returns equivalent of value in hours
//     
//     - returns: Int for number of hours in value
//     */
//    open func hours() -> Int {
//        switch period {
//        case .hours: return value
//        case .minutes: return value / 60
//        default: return 0
//        }
//    }
//    
//    /**
//     Transforms value and period into string.
//     
//     - returns: String as "34 min" or "1 hr"
//     */
//    open func shortDescription() -> String {
//        return "\(value) \(period.shortDescription())"
//    }
//}
//
//extension Endurance: NSCoding {
//    public func encode(with aCoder: NSCoder) {
//        aCoder.encode(value, forKey: "value")
//        aCoder.encode(period.rawValue, forKey: "period")
//    }
//}
//
