//
//  ProfileConverter.swift
//  TimeSlowerKit
//
//  Created by Oleksandr Shcherbakov on 9/7/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation
import TimeSlowerDataBase

public struct ProfileConverter: PersistableConverter {
    
    public func objectFromEntity(_ entity: ManagedObject, parentObject: Persistable?) -> Persistable {
        guard let
            entity = entity as? ProfileEntity,
            let gender = Gender(rawValue: entity.gender.intValue)
        else {
            fatalError("Gender is not convertable")
        }
        
        var photo: UIImage?
        if let photoData = entity.photo {
            photo = UIImage(data: photoData)
        }
        
        let profile = Profile(
            name: entity.name,
            country: entity.country,
            dateOfBirth: entity.birthday,
            gender: gender,
            maxAge: entity.maxAge.doubleValue,
            photo: photo)
        
        return profile
    }
    
    public func configurationFromObject(_ object: Persistable) -> EntityConfiguration {
        guard let
            profile = object as? Profile,
            let gender = ProfileEntity.Gender(rawValue: profile.gender.rawValue)
        else {
            fatalError("Profile Gender unrecognized")
        }
        
        return ProfileConfiguration(
            name: profile.name, 
            birthday: profile.dateOfBirth, 
            country: profile.country, 
            gender: gender, 
            photo: profile.photo, 
            resourceId: profile.resourceId)
    }
}
