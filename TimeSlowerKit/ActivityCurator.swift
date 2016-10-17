//
//  ActivityCurator.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 10/15/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation

/** 
 Class responsible for updating Activities on App Launch.
 For example, activity was started, but not finished neither through notifications, 
 nor manually. Curator checks if it's due and creates result for failed activities.
 It also handles LocalNotification's interactions with Activity instance
 */
internal struct ActivityCurator {
    
    private let dataStore: DataStore
    private let scheduler: ActivityScheduler
    
    init(withDataStore dataStore: DataStore = DataStore()) {
        self.dataStore = dataStore
        scheduler = ActivityScheduler(withDataStore: dataStore)
    }
    
    
    
}
