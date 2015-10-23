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
    
    enum Gender: Int {
        case Male = 0
        case Female = 1
    }
    
    // MARK: - Creation
    class func userProfileInManagedContext(context: NSManagedObjectContext!) -> Profile {
        
        let entity = NSEntityDescription.entityForName("Profile", inManagedObjectContext: context)
        let profile = Profile(entity: entity!, insertIntoManagedObjectContext: context)
        profile.birthday = defaultBirthday()
        profile.country = defaultCountry()!
        profile.gender = 0
        profile.dateOfDeath = profile.dateOfApproximateLifeEnd()
    
        profile.saveChangesToCoreData()
        
        return profile
    }
    
    func saveChangesToCoreData() {
        var error: NSError?
        if !managedObjectContext!.save(&error) { print("Could not save: \(error)") }
    }
    
    func userAge() -> Double {
        let components = NSCalendar.currentCalendar().components(NSCalendarUnit.CalendarUnitYear,
            fromDate: birthday, toDate: NSDate(), options: NSCalendarOptions.allZeros)
        return Double(components.year)
    }
    
    func userGender() -> Gender {
        return Gender(rawValue: gender.integerValue)!
    }
    
    func userGenderString() -> String {
        return (gender.integerValue == 0) ? "Male" : "Female"
    }
    
    func genderWithEnum(gender: Gender) -> NSNumber {
        return NSNumber(integer: gender.rawValue)
    }
    
    func yearsLeftForProfile() -> Double {
        let lifeInContries = Profile.lifeExpacityDictionary()
        var keyForTopDictionary = country.capitalizedString.stringByReplacingOccurrencesOfString(" ", withString: "", options: nil, range: nil)
        var keyForInnerDictionary = userGenderString()
        var maxYears = lifeInContries[keyForTopDictionary]![keyForInnerDictionary]!
        return (maxYears as NSString).doubleValue - userAge()
    }
    
    func dateOfApproximateLifeEnd() -> NSDate {
        let components = NSDateComponents()
        components.setValue(Int(yearsLeftForProfile()), forComponent: .CalendarUnitYear)
        return NSCalendar.currentCalendar().dateByAddingComponents(components, toDate: NSDate(), options: nil)!
    }
    
    func totalTimeSaved() -> Int {
        var totalSaved: Int = 0
        
        for activity in allActivities() {
            if activity.isRoutine() {
                totalSaved += activity.timing.timeToSave.integerValue
            }
        }
        return totalSaved
    }
    
    func totalTimeUsed() -> Int {
        var totalUsed: Int = 0
        for activity in allActivities() {
            if !activity.isRoutine() {
                totalUsed += activity.timing.duration.integerValue
            }
        }
        return totalUsed
    }
    
    
    class func defaultBirthday() -> NSDate {
        var components = NSDateComponents()
        components.setValue(28, forComponent: .CalendarUnitDay)
        components.setValue(3, forComponent: .CalendarUnitMonth)
        components.setValue(1987, forComponent: .CalendarUnitYear)
        
        let birthday = NSCalendar.currentCalendar().dateFromComponents(components)
        return birthday!
    }
    
    class func defaultCountry() -> String? {
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
        let path = NSBundle.mainBundle().pathForResource("ISOCodes", ofType: "txt")
        var error: NSError?
        let ISOCodes = NSString(contentsOfFile: path!, encoding: NSUTF8StringEncoding, error: &error)
        
        var dictionary = [String:String]()
        let components = ISOCodes?.componentsSeparatedByString("\r") as! [String]
        
        var countryName: String!
        var countryCode: String!
        for str in components {
            let countryData = str.componentsSeparatedByString("/")
            dictionary[countryData[1]] = countryData[0]
        }
        
        return dictionary
    }
    
    class func lifeExpacityDictionary() -> [String:[String:String]] {
        let path = NSBundle.mainBundle().pathForResource("LifeExpacity2013", ofType: "txt")
        var error: NSError?
        let contentsOfFile = NSString(contentsOfFile: path!, encoding: NSUTF8StringEncoding, error: &error)
        let countryLines = contentsOfFile?.componentsSeparatedByString("\n") as! [String]!

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