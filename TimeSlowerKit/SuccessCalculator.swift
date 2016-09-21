//
//  SuccessCalculator.swift
//  TimeSlowerKit
//
//  Created by Oleksandr Shcherbakov on 9/4/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation

public struct SuccessCalculator {
    
    public init() { }
    
    func successForActivityType(_ type: ActivityType) -> ((_ start: Date, _ finish: Date, _ maxDuration: Double, _ goal: Double) -> Double) {
        switch type {
        case .routine: return successForRoutine
        case .goal: return successForGoal
        }
    }
    
    /**
     Defines success of routine
     
     - parameter start:       NSDate for fact start
     - parameter finish:      NSDate for fact finish
     - parameter maxDuration: Double for initial duration of routine
     - parameter goal:        Double for time to save of routine
     
     - returns: Double for % of success. Can't be negative.
     */
    func successForRoutine(start: Date,
        finish: Date,
        maxDuration: Double,
        goal: Double) -> Double {
        
        let factDuration = TimeMachine().minutesFromStart(start, toFinish: finish)
        let factSavedTime =  maxDuration - factDuration
        if factSavedTime < 0 {
            return 0
        } else {
            return factSavedTime / goal * 100.0
        }
    }
    
    /**
     Defines success for goal base of fact duration and planned duration
     
     - parameter start:       NSDate for fact start
     - parameter finish:      NSDate for fact finish
     - parameter maxDuration: Double for initial duration of goal
     - parameter goal:        not used
     
     - returns: Double for % of success. Can't be negative.
     */
    func successForGoal(start: Date,
        finish: Date,
        maxDuration: Double,
        goal: Double) -> Double {
        
        let factDuration = TimeMachine().minutesFromStart(start, toFinish: finish)
        if factDuration > 0 {
            return factDuration / maxDuration * 100.0
        } else {
            return 0
        }
    }
    
}
