//
//  PastPeriod.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 8/21/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

/**
 Enum that describes period of time in the past
 
 - Today:     Current day
 - LastMonth: Last month
 - LastYear:  Last year
 */
public enum PastPeriod: Int {
    case today
    case lastMonth
    case lastYear
    
    public func stringForPeriod(_ period: PastPeriod) -> String {
        switch period {
        case .today: return "Today"
        case .lastMonth: return "Last month"
        case .lastYear: return "Last year"
        }
    }
}
