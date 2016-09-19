//
//  StaticDateFormatter.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 8/14/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

/// Class that holds singletons to predefined static NSDateFormatter instances. 
public final class StaticDateFormatter {
    
    fileprivate init() { } // This prevents others from using the default initializer
    
    public static let shortDateNoTimeFromatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        dateFormatter.locale = Locale.current
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = .short
        return dateFormatter
    }()
    
    public static let shortTimeNoDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        dateFormatter.locale = Locale.current
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .none
        return dateFormatter
    }()
    
    public static let shortDateAndTimeFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        dateFormatter.locale = Locale.current
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()
}
