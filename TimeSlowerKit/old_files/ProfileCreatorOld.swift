////
////  ProfileCreator.swift
////  TimeSlower
////
////  Created by Oleksandr Shcherbakov on 8/28/16.
////  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
////
//
//import CoreData
//
//// TODO: create real singleton here
///**
// *  Struct responsible for creating Profile
// */
//internal struct ProfileCreator {
//    
//    /**
//     Main method to create profile from given data. If Profile instance is
//     
//     - parameter name:     String for name
//     - parameter birthday: NSDate for birthday
//     - parameter country:  String for country
//     - parameter avatar:   UIImage optional
//     - parameter gender:   Profile.Gender
//     
//     - returns: Profile instance
//     */
//    internal func saveProfile(withName
//        name: String,
//        birthday: Date,
//        country: String,
//        avatar: UIImage?,
//        gender: Profile.Gender) -> Profile {
//        
//        guard let context = CoreDataStack.sharedInstance.managedObjectContext else {
//            fatalError("Can't find shared managed object context")
//        }
//        
//        let profile = userProfileInManagedContext(context)
//        updateProfile(profile, name: name, birthday: birthday, country: country, avatar: avatar, gender: gender)
//        return profile
//    }
//    
//    // MARK: - Private Methods
//    
//    /**
//     Creates base profile in given ontext or return one that is created before.
//     
//     - parameter context: NSManagedObjectContext
//     
//     - returns: Profile instance
//     */
//    internal func userProfileInManagedContext(_ context: NSManagedObjectContext) -> Profile {
//        
//        guard let entity = NSEntityDescription.entity(forEntityName: "Profile", in: context) else {
//            fatalError("No entity named Profile in given context")
//        }
//        
//        if let profile = Profile.fetchProfile() {
//            return profile
//        } else {
//            let profile = Profile(entity: entity, insertInto: context)
//            profile.name = "Anonymous"
//            profile.birthday = Profile.defaultBirthday()
//            profile.country = Profile.defaultCountry()
//            profile.gender = 0
//            profile.dateOfDeath = profile.dateOfApproximateLifeEnd()
//            
//            Profile.saveContext(context)
//            return profile
//        }
//    }
//    
//    fileprivate func updateProfile(_ profile: Profile, name: String, birthday: Date, country: String, avatar: UIImage?, gender: Profile.Gender) {
//        
//        profile.name = name
//        profile.birthday = birthday
//        profile.country = country
//        profile.gender = Profile.genderWithEnum(gender)
//        if let photo = Profile.imageForSelectedAvatar(avatar) {
//            profile.photo = UIImagePNGRepresentation(photo)
//        }
//        
//        Profile.saveContext(profile.managedObjectContext)
//    }
//}
