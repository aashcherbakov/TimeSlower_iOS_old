//
//  ActivityType.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 8/7/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation

/**
 Enum that describes Activity Type - currently Routine or Goal
 
 - Routine: Routine - daily activity on which user ought to save time
 - Goal:    Goal - activity that user wants to spend time on
 */
public enum ActivityType: Int {
    case Routine
    case Goal
}
