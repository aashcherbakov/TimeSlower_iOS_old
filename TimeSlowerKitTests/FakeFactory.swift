//
//  FakeFactory.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 11/24/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation
import TimeSlowerKit

internal struct FakeFactory {
    static let shortDateFormatter = StaticDateFormatter.shortDateNoTimeFromatter

    static func profile() -> Profile {
        return Profile(
            name: "Alex",
            country: "United States",
            dateOfBirth: shortDateFormatter.date(from: "3/28/1987")!,
            gender: .male,
            maxAge: 79.0,
            photo: nil)
    }
    
}
