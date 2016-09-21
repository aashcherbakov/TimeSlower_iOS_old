//
//  ResultConverter.swift
//  TimeSlowerKit
//
//  Created by Alexander Shcherbakov on 9/8/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import TimeSlowerDataBase

internal struct ResultConverter: PersistableConverter {
    
    func objectFromEntity(_ entity: ManagedObject, parentObject: Persistable?) -> Persistable {
        guard let activity = parentObject as? Activity else {
            fatalError("Wrong entity")
        }
        
        let result = Result(withActivity: activity)
        return result
    }
    
    
    func configurationFromObject(_ object: Persistable) -> EntityConfiguration {
        guard let object = object as? Result else {
            fatalError("Wrong object")
        }
        
        return ResultConfiguration(
            stringDate: object.stringDate, 
            duration: object.duration, 
            startTime: object.startTime, 
            finishTime: object.finishTime, 
            savedTime: object.savedTime, 
            success: object.success, 
            date: object.finishTime, 
            resourceId: object.resourceId)
    }
}
