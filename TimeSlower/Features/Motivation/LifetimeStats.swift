//
//  LifetimeStats.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 7/17/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation

internal struct LifetimeStats {
    let summHours: NSNumber
    let summDays: NSNumber
    let summMonth: NSNumber
    let summYears: NSNumber
    
    init(withHours hours: NSNumber) {
        summHours = hours
        summDays = hours.doubleValue / 24
        summMonth = summDays.doubleValue / 30
        summYears = summMonth.doubleValue / 12
    }
    
    func hoursValueString() -> String {
        return "\(summHours.integerValue)"
    }
    
    func daysValueString() -> String {
        return String(format: "%.1f", summDays.doubleValue)
    }
    
    func monthsValueString() -> String {
        return String(format: "%.1f", summMonth.doubleValue)
    }
    
    func yearsValueString() -> String {
        return String(format: "%.1f", summYears.doubleValue)
    }
    
    func hoursDescription() -> String {
        return "\(hoursValueString()) HOURS"
    }
    
    func daysDescription() -> String {
        return "\(daysValueString()) DAYS"
    }
    
    func monthsDescription() -> String {
        return "\(monthsValueString()) MONTHS"
    }
    
    func yearsDescription() -> String {
        return "\(yearsValueString()) YEARS"
    }
}