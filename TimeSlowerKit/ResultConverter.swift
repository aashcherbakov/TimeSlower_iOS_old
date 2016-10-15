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
        
        guard let resultEntity = entity as? ResultEntity else {
            fatalError("Wrong entity")
        }
        
        var activity: Activity
        if let parent = parentObject as? Activity {
            activity = parent
        } else {
            activity = ActivityConverter().objectFromEntity(resultEntity.activity, parentObject: nil) as! Activity
        }
        
        let result = Result(
            withDate: resultEntity.stringDate,
            startTime: resultEntity.startTime,
            finishTime: resultEntity.finishTime,
            duration: resultEntity.duration.doubleValue,
            success: resultEntity.success.doubleValue,
            savedTime: resultEntity.savedTime?.doubleValue,
            activity: activity,
            resourceId: resultEntity.resourceId)
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
    
    public func objectsFromEntities(_ entities: [ManagedObject], parent: Persistable?) -> [Persistable] {
        guard let resultEntities = entities as? [ResultEntity] else {
            assertionFailure("Passed entities are not of ResultEntity type")
            return []
        }
        
        var results: [Persistable] = []
        for resultEntity in resultEntities {
            let object = objectFromEntity(resultEntity, parentObject: parent)
            results.append(object)
        }
        
        return results
    }
}
