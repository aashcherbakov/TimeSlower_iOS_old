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
    
}
