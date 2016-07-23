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
    
    func hoursAttributedDescription() -> NSAttributedString {
        return attributedDescription(hoursValueString(), period: "HOURS")
    }
    
    func daysAttributedDescription() -> NSAttributedString {
        return attributedDescription(daysValueString(), period: "DAYS")
    }
    
    func monthsAttributedDescription() -> NSAttributedString {
        return attributedDescription(monthsValueString(), period: "MONTHS")
    }
    
    func yearsAttributedDescription() -> NSAttributedString {
        return attributedDescription(yearsValueString(), period: "YEARS")
    }
    
    private func attributedDescription(valueString: String, period: String) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: "\(valueString) \(period)")
        let boldRange = NSMakeRange(0, valueString.characters.count)
        
        let defaultAttributes = [
            NSFontAttributeName            : UIFont.mainRegular(14),
            NSForegroundColorAttributeName : UIColor.whiteColor()
        ]
        
        attributedString.addAttributes(defaultAttributes, range: NSMakeRange(0, attributedString.length))
        attributedString.addAttribute(NSFontAttributeName, value: UIFont.mainBold(15), range: boldRange)
        return attributedString
    }
    
}