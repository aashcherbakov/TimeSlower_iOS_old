//
//  Day.swift
//  TimeSlowerKit
//
//  Created by Oleksandr Shcherbakov on 9/3/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation

open class Day: NSObject {
    open let number: Int
    
    public required init?(coder aDecoder: NSCoder) {
        self.number = aDecoder.decodeInteger(forKey: "number")
    }
    
    public init(number: Int) {
        self.number = number
    }
    
    open func encodeWithCoder(_ aCoder: NSCoder) {
        aCoder.encode(number, forKey: "number")
    }
    
    open override func isEqual(_ object: Any?) -> Bool {
        if let day = object as? Day {
            return number == day.number
        }
        
        return false
    }
    
    /// Copy from the way we treat Weekday - see public enum
    public static func createFromDate(_ date: Date) -> Day {
        let day = Calendar.current.component(.weekday, from: date)
        return Day(number: (day - 1) % 7)
    }
}
