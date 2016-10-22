//
//  ProfileCreator.swift
//  TimeSlower
//
//  Created by Alexander Shcherbakov on 10/21/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation
import TimeSlowerKit

internal struct ProfileCreator {
    
    private let dataStore: DataStore
    private let dateFormatter = StaticDateFormatter.fullDateFormatter
    
    init(withDataStore dataStore: DataStore = DataStore()) {
        self.dataStore = dataStore
    }
    
    func saveProfile(profile: Profile, withProperties properties: ProfileData) -> Profile {
        let updatedBirthday = getProfileDateOfBirth(fromString: properties.birthday)
        let updatedProfile = Profile(fromProfile: profile, name: properties.name, dateOfBirth: updatedBirthday, country: properties.country, photo: properties.image)
        let savedProfile = dataStore.update(updatedProfile)
        return savedProfile
    }
    
    func createProfile(withName name: String, country: String, birthday: String, image: UIImage?) -> Profile {
        let date = getProfileDateOfBirth(fromString: birthday)
        
        let profile = Profile(
            name: name,
            country: country,
            dateOfBirth: date,
            gender: .female,
            maxAge: 77.4,
            photo: image)
        
        let newProfile: Profile = dataStore.create(profile)
        return newProfile
    }
    
    // MARK: - Private

    private func getProfileDateOfBirth(fromString string: String) -> Date {
        if let dateOfBirth = dateFormatter.date(from: string) {
            return dateOfBirth
        } else {
            return Profile.defaultBirthday()
        }
    }
    
}
