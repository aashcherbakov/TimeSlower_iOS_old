//
//  Profile+Manage.swift
//  TimeSlower2
//
//  Created by Aleksander Shcherbakov on 5/1/15.
//  Copyright (c) 2015 1lastDay. All rights reserved.
//

import Foundation
import CoreData

extension Profile {
    
    public enum Gender: Int {
        case Male = 0
        case Female = 1
        
        func description() -> String {
            switch self {
            case .Male: return "Male"
            case .Female: return "Female"
            }
        }
    }
    
    public struct LifeTime {
        public var years: Double
        public var months: Double
        public var days: Double
        public var hours: Double
    }
    
    public struct DailyStats {
        public var factSaved: Double
        public var factSpent: Double
        public var plannedToSave: Double
        public var plannedToSpend: Double
    }
    
    // MARK: - Creation and fetching
    
    /**
     Main method to create profile from given data. If Profile instance is
     
     - parameter name:     String for name
     - parameter birthday: NSDate for birthday
     - parameter country:  String for country
     - parameter avatar:   UIImage optional
     - parameter gender:   Profile.Gender
     
     - returns: Profile instance
     */
    public static func saveProfile(withName
        name: String,
        birthday: NSDate,
        country: String,
        avatar: UIImage?,
        gender: Profile.Gender) -> Profile {
        
        return ProfileCreator().saveProfile(withName: name, birthday: birthday, country: country, avatar: avatar, gender: gender)
    }
    
    /**
     Sets default image if user did not select his avatar
     
     - parameter avatar: UIImage from Profile photo property
     
     - returns: UIImage with avatar
     */
    public class func imageForSelectedAvatar(avatar: UIImage?) -> UIImage? {
        if let avatar = avatar {
            return avatar
        } else {
            return UIImage(named: "defaultUserImage")
        }
    }
    
    /**
     Fetches profile from shared core data stack.
     
     - returns: Profile?
     
     - warning: Don't use in XCTest!
     */
    public class func fetchProfile() -> Profile? {
        return CoreDataStack.sharedInstance.fetchProfile()
    }
    
    //MARK: - User Properties
    
    /**
     Returns user age.
     
     - returns: Double for user age
     */
    public func userAge() -> Double {
        let components = NSCalendar.currentCalendar().components(.Year, fromDate: birthday, toDate: NSDate(), options: [])
        return Double(components.year)
    }
    
    /**
     Returns Gender based of saved gender value in Profile
     
     - returns: Gender enum
     */
    public func userGender() -> Gender {
        guard let gender = Gender(rawValue: gender.integerValue) else {
            fatalError("Used unallowed integer to create gender")
        }
        return gender
    }
    
    /**
     Provides string description for user gender
     
     - returns: "Male" of "Female"
     */
    public func userGenderString() -> String {
        return userGender().description()
    }
    
    /**
     Transforms given gender value into NSNumber instance
     
     - parameter gender: Gender instance
     
     - returns: 0 for male, 1 for female
     */
    public class func genderWithEnum(gender: Gender) -> NSNumber {
        return NSNumber(integer: gender.rawValue)
    }
    
    
    //MARK: - Life expacity stats
    
    /**
     Returns difference between years left for profile based of life expacity and current user age.
     
     - returns: Double
     */
    public func yearsLeftForProfile() -> Double {
        return maxYearsForProfile() - userAge()
    }
    
    /**
     Returns life expactancy for user of given age in given country
     
     - returns: Double for average expected years to live
     */
    public func maxYearsForProfile() -> Double {
        let lifeInContries = Profile.lifeExpacityDictionary()
        let keyForTopDictionary = country.capitalizedString.stringByReplacingOccurrencesOfString(" ", withString: "", options: [], range: nil)
        let keyForInnerDictionary = userGenderString()
        return (lifeInContries[keyForTopDictionary]![keyForInnerDictionary]! as NSString).doubleValue
    }
    
    /**
     Returns date of approximate death based of maximum years in chosen country with chosen gender
     
     - returns: NSDate of avarage person's death
     */
    public func dateOfApproximateLifeEnd() -> NSDate {
        let components = NSDateComponents()
        components.setValue(Int(maxYearsForProfile()), forComponent: .Year)
        return NSCalendar.currentCalendar().dateByAddingComponents(components, toDate: birthday, options: [])!
    }
    
    /**
     Returns number of days between given date and dateOfApproximateLifeEnd() value
     
     - parameter date: NSDate to start countdown
     
     - returns: Int for number of days
     */
    public func numberOfDaysTillEndOfLifeSinceDate(date: NSDate) -> Int {
        let components = NSCalendar.currentCalendar().components(
            .Day, fromDate: date, toDate: dateOfApproximateLifeEnd(), options: [])
        return components.day
    }
    

    
    
    public func totalTimeForDailyMinutes(minutes: Double) -> LifeTime {
        let minutes = Double(minutes)
        let daysLeft = Double(numberOfDaysTillEndOfLifeSinceDate(NSDate()))
        
        let hours = minutes * daysLeft / 60.0
        let days = hours / 24
        let months = days / 30
        let years = months / 12
        return LifeTime(years: years, months: months, days: days, hours: hours)
    }
    
    
    
    /// Returns $0 - saved, $1 - spent
    public func factTimingForPeriod(period: PastPeriod) -> (saved: Double, spent: Double)? {

        var summSaved = 0.0
        var summSpent = 0.0
        
        for activity in allActivities() {
            for result in activity.unitTesting_allResultsForPeriod(period) {
                if activity.isRoutine() {
                    summSaved += result.factSavedTime!.doubleValue
                } else {
                    summSpent += result.factDuration.doubleValue
                }
            }
        }
        return (summSaved, summSpent)
    }
    
    /// Returns $0 - saved, $1 - spent in minutes
    public func plannedTimingInPeriod(period: PastPeriod, sinceDate date: NSDate) -> (save: Double, spend: Double)? {
        var toSave = 0.0;
        var toSpend = 0.0;
        
        for activity in allActivities() {
            let numberOfDays = activity.stats.busyDaysForPeriod(period, sinceDate: date)
            if activity.isRoutine() {
                toSave += activity.timing.timeToSave.doubleValue * Double(numberOfDays)
            } else {
                toSpend += Double(activity.timing.duration.minutes()) * Double(numberOfDays)
            }
        }
        return (abs(toSave), abs(toSpend)) // minutes
    }
    
    public func timeStatsForPeriod(period: PastPeriod) -> DailyStats {
        let fact = factTimingForPeriod(period)
        let planned = plannedTimingInPeriod(period, sinceDate: NSDate())
        return DailyStats(factSaved: fact!.0, factSpent: fact!.1, plannedToSave: planned!.0, plannedToSpend: planned!.1)
    }
    
    //    public func timeStatsForToday() -> DailyStats {
    //        let fact = factTimingForToday()
    //        let planned = plannedTimingForToday()
    //        return DailyStats(factSaved: fact.0, factSpent: fact.1, plannedToSave: planned.0, plannedToSpend: planned.1)
    //    }
    
    
    //    /// Returns tuple: $0 = Saved, $1 = Spent
    //    public func factTimingForToday() -> (Double, Double) {
    //        var savedToday = 0.0
    //        var spentToday = 0.0
    //        let allResultsForToday = DayResults.fetchResultsWithDate(NSDate(), inContext: managedObjectContext!)
    //        for result in allResultsForToday {
    //            if result.activity.isRoutine() {
    //                savedToday += result.factSavedTime!.doubleValue
    //            } else {
    //                spentToday += result.factSpentTime()
    //            }
    //        }
    //        return (savedToday, spentToday)
    //    }
    
    //    /// Returns tuple: $0 = toSave, $1 = toSpend
    //    public func plannedTimingForToday() -> (Double, Double) {
    //        var toSpendToday = 0.0
    //        var toSaveToday = 0.0
    //
    //        for activity in activitiesForDate(NSDate()) {
    //            if activity.isRoutine() {
    //                toSaveToday += activity.timing.timeToSave.doubleValue
    //            } else {
    //                toSpendToday += activity.timing.duration.doubleValue
    //            }
    //        }
    //        return (toSaveToday, toSpendToday)
    //    }
    
    
    
    //    public func totalTimePlannedToSave() -> Int {
    //        var totalSaved: Int = 0
    //
    //        for activity in allActivities() {
    //            if activity.isRoutine() {
    //                totalSaved += activity.timing.timeToSave.integerValue
    //            }
    //        }
    //        return totalSaved
    //    }
    //
    //    public func totalTimePlannedToUse() -> Int {
    //        var totalUsed: Int = 0
    //        for activity in allActivities() {
    //            if !activity.isRoutine() {
    //                totalUsed += activity.timing.duration.integerValue
    //            }
    //        }
    //        return totalUsed
    //    }
    
    
 

    
    
    //MARK: - Default settings
    
    /**
     Returns default birthday. Used on profile creation.
     
     - returns: NSDate for March 3 1987
     */
    public class func defaultBirthday() -> NSDate {
        return DayResults.standardDateFormatter().dateFromString("3/28/87")!
    }
    
    /**
     Returns default country based on country code in current locale.
     
     - returns: String with country name of users locale
     */
    public class func defaultCountry() -> String {
        guard let countryCode = NSLocale.currentLocale().objectForKey(NSLocaleCountryCode) as? String else {
            assert(false, "Error: no such code as " + NSLocaleCountryCode + " in current database")
            return ""
        }
        
        if let defaultCode = countryCodesDictionary()[countryCode] {
            return defaultCode
        } else {
            assert(false, "Error: no such code as " + countryCode + " in current database")
            return ""
        }
    }
    
    /**
     Reads ISOCodes file and returns a dictionary with keys for country names and values as codes
     
     - returns: [String:String]
     */
    private class func countryCodesDictionary() -> [String:String] {
        return DataStore().countryCodesDictionary()
    }
    
    /**
     Reads LifeExpacity2013 file and returns dictionary with countries as keys and values for
     life expacity for man and woman
     
     - returns: [String:[String:String]]
     */
    private class func lifeExpacityDictionary() -> [String:[String:String]] {
        return DataStore().lifeExpacityDictionary()
    }
    

}