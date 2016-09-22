//
//  ProfileConfiguration.swift
//  TimeSlowerKit
//
//  Created by Alexander Shcherbakov on 9/7/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation
import UIKit

public struct ProfileConfiguration: EntityConfiguration {
    
    public let birthday: Date
    public let country: String
    public let gender: ProfileEntity.Gender
    public let name: String
    public let photo: UIImage?
    public let resourceId: String

    public init(name: String, birthday: Date, country: String, gender: ProfileEntity.Gender, photo: UIImage?, resourceId: String) {
        
        self.name = name
        self.birthday = birthday
        self.country = country
        self.gender = gender
        self.photo = photo
        self.resourceId = resourceId
    }
}
