//
//  Profile.swift
//  TimeSlowerKit
//
//  Created by Oleksandr Shcherbakov on 9/1/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation

/**
 *  Struct that keeps data about user profile.
 */
public struct Profile: Persistable {
    
    /**
     Represents average age for user in given country with given gender.
     Calculated from LifeExpectancy report stored in DataBase
     */
    public let maxAge: Double
    public let name: String
    public let country: String
    public let dateOfBirth: Date
    public let gender: Gender
    public let photo: UIImage?
    public let resourceId: String

    fileprivate let calendar = Calendar.current
    
    public init(name: String, country: String, dateOfBirth: Date, gender: Gender, maxAge: Double, photo: UIImage?, resourceId: String? = nil) {
        self.name = name
        self.country = country
        self.dateOfBirth = dateOfBirth
        self.gender = gender
        self.photo = photo
        self.maxAge = maxAge
        
        self.resourceId = resourceId ?? UUID().uuidString
    }
    
    /**
     Returns user age.
     
     - returns: Double for user age
     */
    public func userAgeForDate(_ date: Date) -> Double {
        let components = (calendar as NSCalendar).components(.year, from: dateOfBirth, to: date, options: [])
        return Double(components.year!)
    }
    
    /**
     Provides string description for user gender
     
     - returns: "Male" of "Female"
     */
    public func genderDescription() -> String {
        return gender.description()
    }
    
    /**
     Returns date of approximate death based of maximum years in chosen country with chosen gender
     
     - returns: NSDate of avarage person's death
     */
    public func dateOfApproximateLifeEnd() -> Date {
        var components = DateComponents()
        components.setValue(Int(maxAge), for: .year)
        return calendar.date(byAdding: components, to: dateOfBirth)!
    }
    
    /**
     Returns number of days between given date and dateOfApproximateLifeEnd() value
     
     - parameter date: NSDate to start countdown
     
     - returns: Int for number of days
     */
    public func numberOfDaysTillEndOfLifeSinceDate(_ date: Date) -> Int {
        let components = calendar.dateComponents([.day], from: date, to: dateOfApproximateLifeEnd())
        return abs(components.day!)
    }
    
    public static func defaultBirthday() -> Date {
        var components = DateComponents()
        components.year = 1987
        components.month = 3
        components.day = 28
        components.calendar = .current
        
        if let date = Calendar.current.date(from: components) {
            return date
        } else {
            assertionFailure("Could not create date from components")
            return Date()
        }
    }
}
