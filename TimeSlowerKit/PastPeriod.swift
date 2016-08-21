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
    case Today
    case LastMonth
    case LastYear
    
    public func stringForPeriod(period: PastPeriod) -> String {
        switch period {
        case .Today: return "Today"
        case .LastMonth: return "Last month"
        case .LastYear: return "Last year"
        }
    }
}