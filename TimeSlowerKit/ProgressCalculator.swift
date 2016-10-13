//
//  ProgressCalculator.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 10/13/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation

public struct ProgressCalculator {
    private let profile: Profile
    private let dataStore: DataStore
    
    init(withProfile profile: Profile, dataStore: DataStore = DataStore()) {
        self.profile = profile
        self.dataStore = dataStore
    }
    
    public func progressForDate(date: Date = Date()) {
        let activities = dataStore.activities(forDate: date, type: .routine)
        
        var totalSuccess = 0
        for activity in activities {
            
        }
    }
}
