//
//  StaticDateFormatter.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 8/14/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

/// Class that holds singletons to predefined static NSDateFormatter instances. 
public final class StaticDateFormatter {
    
    public static let shortDateNoTimeFromatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        dateFormatter.locale = NSLocale.currentLocale()
        dateFormatter.timeStyle = .NoStyle
        dateFormatter.dateStyle = .ShortStyle
        return dateFormatter
    }()
    
    public static let shortTimeNoDateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        dateFormatter.locale = NSLocale.currentLocale()
        dateFormatter.timeStyle = .ShortStyle
        dateFormatter.dateStyle = .NoStyle
        return dateFormatter
    }()
    
    public static let shortDateAndTimeFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        dateFormatter.locale = NSLocale.currentLocale()
        dateFormatter.dateStyle = .ShortStyle
        dateFormatter.timeStyle = .ShortStyle
        return dateFormatter
    }()
}
