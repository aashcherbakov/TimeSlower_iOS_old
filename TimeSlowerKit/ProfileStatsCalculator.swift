//
//  ProfileStatsCalculator.swift
//  TimeSlowerKit
//
//  Created by Oleksandr Shcherbakov on 9/3/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation

/**
 *  Struct responsible for calculating overall statistics of the whole profile.
 *  Used to display current results achieved by user per period, for example, 
 *  total stats for today, or stats since user started using app.
 */
public struct ProfileStatsCalculator {
    
    public enum StatsPeriod {
        case today
        case overall
    }
    
    public init() { }
    
    public func savedTimeInPeriod(_ period: StatsPeriod) -> Double {
        return 0
    }
    
    public func spentTimeInPeriod(_ period: StatsPeriod) -> Double {
        return 0
    }
    
    public func savingGoalForPeriod(_ period: StatsPeriod) -> Double {
        return 0
    }
    
    public func spendingGoalForPeriod(_ period: StatsPeriod) -> Double {
        return 0
    }
}

