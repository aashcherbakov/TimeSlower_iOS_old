//
//  Profile.swift
//  TimeSlowerDataBase
//
//  Created by Oleksandr Shcherbakov on 9/1/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import UIKit
import CoreData


open class ProfileEntity: ManagedObject {

    @NSManaged open var birthday: Date
    @NSManaged open var country: String
    @NSManaged open var dateOfDeath: Date
    @NSManaged open var gender: NSNumber
    @NSManaged open var name: String
    @NSManaged open var photo: Data?
    @NSManaged open var activities: NSSet
    @NSManaged open var maxAge: NSNumber
    @NSManaged open var resourceId: String

    public enum Gender: Int {
        case male = 0
        case female = 1
        
        func description() -> String {
            switch self {
            case .male: return "Male"
            case .female: return "Female"
            }
        }
    }
    
    /**
     Returns life expactancy for user of given age in given country
     
     - returns: Double for average expected years to live
     */
    open func maxYearsForProfile(_ profile: ProfileEntity) -> Double {
        let lifeInContries = LocalDataReader().lifeExpacityDictionary()
        let keyForTopDictionary = profile.country.capitalized.replacingOccurrences(of: " ", with: "", options: [], range: nil)
        let keyForInnerDictionary = ProfileEntity.Gender(rawValue: profile.gender.intValue)!.description()
        
        if let country = lifeInContries[keyForTopDictionary], let genderAge = country[keyForInnerDictionary], let doubleValue = Double(genderAge) {
            
            return doubleValue
        }
        
        return 76
    }
    
    // MARK: - Private
    
    /// March 3 1987
    fileprivate func defaultBirthday() -> Date {
        return DefaultDateFormatter.shortDateNoTimeFromatter.date(from: "3/28/87")!
    }
    
    
    /// United States
    fileprivate func defaultCountry() -> String {
        guard let countryCode = (Locale.current as NSLocale).object(forKey: NSLocale.Key.countryCode) as? String else {
            assert(false, "Error: no such code as \(NSLocale.Key.countryCode) in current database")
            return ""
        }
        
        if let defaultCode = LocalDataReader().countryCodesDictionary()[countryCode] {
            return defaultCode
        } else {
            assert(false, "Error: no such code as " + countryCode + " in current database")
            return ""
        }
    }
}

extension ProfileEntity: ManagedObjectType {
    public static var entityName: String {
        return self.className
    }
    
    public func setDefaultPropertiesForObject() {
        name = "Anonymous"
        birthday = defaultBirthday()
        country = defaultCountry()
        gender = 0
        dateOfDeath = Date()
        resourceId = ""
    }
    
    public func updateWithConfiguration(_ configuration: EntityConfiguration) {
        guard let configuration = configuration as? ProfileConfiguration else {
            fatalError("Unrecognized configuration")
        }
        
        let oldBirthDay = birthday
        let oldCountry = country
        
        name = configuration.name
        birthday = configuration.birthday as Date
        country = configuration.country
        gender = NSNumber(value: configuration.gender.rawValue)
        
        if let avatar = configuration.photo {
            photo = UIImagePNGRepresentation(avatar)
        }
        
        if configuration.birthday as Date != oldBirthDay || configuration.country != oldCountry {
            maxAge = NSNumber(value: maxYearsForProfile(self))
        }
        
        if resourceId == "" {
            resourceId = configuration.resourceId
        }
    }
    
    public func setParent(_ parent: ManagedObject?) {
        // no parent needed
    }
}

