//
//  Destination.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 12/18/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation
import TimeSlowerKit

internal enum Destination {
    
    case home(profile: Profile)
    case menu(profile: Profile)
    case editProfile(profile: Profile?)
    case profileStats(profile: Profile)
    case editActivity(profile: Profile, activity: Activity?)
    case activityStats(activity: Activity)
    case activities(profile: Profile)
    case motivation(activity: Activity)
    
}
