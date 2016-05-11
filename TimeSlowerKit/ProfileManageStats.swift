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
    public class func userProfileInManagedContext(context: NSManagedObjectContext!) -> Profile {
        
        let entity = NSEntityDescription.entityForName("Profile", inManagedObjectContext: context)
        let profile = Profile(entity: entity!, insertIntoManagedObjectContext: context)
        profile.birthday = defaultBirthday()
        profile.country = defaultCountry()!
        profile.gender = 0
        profile.dateOfDeath = profile.dateOfApproximateLifeEnd()
        
        profile.saveChangesToCoreData()
        
        return profile
    }
    
    public class func saveProfile(withName name: String, birthday: NSDate, country: String,
        avatar: UIImage?, gender: Profile.Gender) {
        var profile = fetchProfile()
        
        if profile == nil {
            guard let context = CoreDataStack.sharedInstance.managedObjectContext else { return }
            profile = Profile.userProfileInManagedContext(context)
        }
        
        if let profile = profile {
            profile.name = name
            profile.birthday = birthday
            profile.country = country
            profile.gender = Profile.genderWithEnum(gender)
            profile.photo = UIImagePNGRepresentation(imageForSelectedAvatar(avatar))!
            profile.saveChangesToCoreData()
        }
    }
    
    public class func imageForSelectedAvatar(avatar: UIImage?) -> UIImage {
        if let avatar = avatar {
            return avatar
        } else {
            return UIImage(named: "defaultUserImage")!
        }
    }
    
    /// Don't use in XCTest !
    public class func fetchProfile() -> Profile? {
        return CoreDataStack.sharedInstance.fetchProfile()
    }
    
    public func saveChangesToCoreData() {
        var error: NSError?
        do {
            try managedObjectContext!.save()
        } catch let error1 as NSError { error = error1; print("Profile error: could not save: \(error)") }
    }
    
    //MARK: - User Properties
    
    public func userAge() -> Double {
        let components = NSCalendar.currentCalendar().components(NSCalendarUnit.Year,
            fromDate: birthday, toDate: NSDate(), options: NSCalendarOptions())
        return Double(components.year)
    }
    
    public func userGender() -> Gender {
        return Gender(rawValue: gender.integerValue)!
    }
    
    public func userGenderString() -> String {
        return (gender.integerValue == 0) ? "Male" : "Female"
    }
    
    public class func genderWithEnum(gender: Gender) -> NSNumber {
        return NSNumber(integer: gender.rawValue)
    }
    
    
    //MARK: - Life expacity stats
    
    public func yearsLeftForProfile() -> Double {
        return maxYearsForProfile() - userAge()
    }
    
    public func maxYearsForProfile() -> Double {
        let lifeInContries = Profile.lifeExpacityDictionary()
        let keyForTopDictionary = country.capitalizedString.stringByReplacingOccurrencesOfString(" ", withString: "", options: [], range: nil)
        let keyForInnerDictionary = userGenderString()
        return (lifeInContries[keyForTopDictionary]![keyForInnerDictionary]! as NSString).doubleValue
    }
    
    public func dateOfApproximateLifeEnd() -> NSDate {
        let components = NSDateComponents()
        components.setValue(Int(maxYearsForProfile()), forComponent: .Year)
        return NSCalendar.currentCalendar().dateByAddingComponents(components, toDate: birthday, options: [])!
    }
    
    
    //MARK: - Timing stats
    
    
    
    //TODO: move to profile
    /// Returns $0 - saved, $1 - spent
    public func factTimingForPeriod(period: LazyCalendar.Period) -> (Double, Double)? {

        
        var summSaved = 0.0
        var summSpent = 0.0
        
        for activity in allActivities() {
            if let stats = activity.stats {
                for result in stats.allResultsForPeriod(period) {
                    if activity.isRoutine() {
                        summSaved += result.factSavedTime!.doubleValue
                    } else {
                        summSpent += result.factDuration.doubleValue
                    }
                }
            }
            
        }
        return (summSaved, summSpent)
    }
    
    //TODO: move to profile
    /// Returns $0 - saved, $1 - spent in minutes
    public func plannedTimingInPeriod(period: LazyCalendar.Period, sinceDate date: NSDate) -> (Double, Double) {
        var toSave = 0.0;
        var toSpend = 0.0;
        
        for activity in allActivities() {
            let numberOfDays = activity.stats!.busyDaysForPeriod(period, sinceDate: date)
            if activity.isRoutine() {
                toSave += activity.timing!.timeToSave.doubleValue * Double(numberOfDays)
            } else {
                toSpend += activity.timing!.duration.doubleValue * Double(numberOfDays)
            }
        }
        return (abs(toSave), abs(toSpend)) // minutes
    }
    
    public func timeStatsForPeriod(period: LazyCalendar.Period) -> DailyStats {
        let fact = factTimingForPeriod(period)
        let planned = plannedTimingInPeriod(period, sinceDate: NSDate())
        return DailyStats(factSaved: fact!.0, factSpent: fact!.1, plannedToSave: planned.0, plannedToSpend: planned.1)
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
    
    
    public func totalTimeForDailyMinutes(minutes: Double) -> LifeTime {
        let minutes = Double(minutes)
        let daysLeft = Double(numberOfDaysTillEndOfLifeSinceDate(NSDate()))
        
        let hours = minutes * daysLeft / 60.0
        let days = hours / 24
        let months = days / 30
        let years = months / 12
        return LifeTime(years: years, months: months, days: days, hours: hours)
    }
    
    public func numberOfDaysTillEndOfLifeSinceDate(date: NSDate) -> Int {
        let components = NSCalendar.currentCalendar().components(.Day,
            fromDate: date,
            toDate: dateOfApproximateLifeEnd(),
            options: [])
        return components.day
    }
    
    
    
    //MARK: - Default settings
    
    public class func defaultBirthday() -> NSDate {
        return DayResults.standardDateFormatter().dateFromString("3/28/87")!
    }
    
    public class func defaultCountry() -> String? {
        let countryCode = NSLocale.currentLocale().objectForKey(NSLocaleCountryCode) as! String
        let codesForCountries = countryCodesDictionary()
        if let defaultCode = codesForCountries[countryCode] {
            return defaultCode
        } else {
            print("Error: no such code as " + countryCode + " in current database")
        }
        return nil
    }
    
    
    class func countryCodesDictionary() -> [String:String] {
        let path = NSBundle(identifier: "oneLastDay.TimeSlowerKit")!.pathForResource("ISOCodes", ofType: "txt")
        let ISOCodes: NSString?
        do {
            ISOCodes = try NSString(contentsOfFile: path!, encoding: NSUTF8StringEncoding)
        } catch _ as NSError {
            ISOCodes = nil
        }
        
        var dictionary = [String:String]()
        let components = ISOCodes!.componentsSeparatedByString("\r")
        
        for str in components {
            let countryData = str.componentsSeparatedByString("/")
            dictionary[countryData[1]] = countryData[0]
        }
        
        return dictionary
    }
    
    class func lifeExpacityDictionary() -> [String:[String:String]] {
        let bundle = NSBundle(identifier: "oneLastDay.TimeSlowerKit")
        let path = bundle!.pathForResource("LifeExpacity2013", ofType: "txt")
        let contentsOfFile: NSString?
        do {
            contentsOfFile = try NSString(contentsOfFile: path!, encoding: NSUTF8StringEncoding)
        } catch _ as NSError {
            contentsOfFile = nil
        }
        let countryLines = contentsOfFile?.componentsSeparatedByString("\n") as [String]!
        
        var allCountries = [String:[String:String]]()
        for string in countryLines {
            if string != "" {
                let countryData = string.componentsSeparatedByString("/")
                let countryDataDictionary = ["Average": countryData[2], "Male": countryData[3], "Female": countryData[5]]
                let countryName = countryData[1]
                allCountries[countryName] = countryDataDictionary
            }
        }
        return allCountries
    }
}