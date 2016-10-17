//
//  Activity.swift
//  TimeSlowerDataBase
//
//  Created by Oleksandr Shcherbakov on 9/1/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation
import CoreData

open class ActivityEntity: ManagedObject {

    @NSManaged open var name: String
    @NSManaged open var type: NSNumber
    @NSManaged open var days: [Day]
    @NSManaged open var timing: TimingData
    @NSManaged open var stats: StatsData
    @NSManaged open var notifications: NSNumber
    @NSManaged open var results: NSSet
    @NSManaged open var resourceId: String
    
    @NSManaged open var averageSuccess: NSNumber
    @NSManaged open var totalResults: NSNumber
    @NSManaged open var totalTimeSaved: NSNumber

    public enum ActivityType: Int {
        case routine
        case goal
    }

}

extension ActivityEntity: ManagedObjectType {
    public static var entityName: String {
        return self.className
    }
    
    public func setDefaultPropertiesForObject() {
        name = "No name"
        type = 1
        notifications = false
        days = []
        timing = TimingData(duration: Continuation(value: 0, period: .minutes), alarmTime: Date(), startTime: Date(), timeToSave: 0)
        stats = StatsData(days: 0, hours: 0, months: 0, years: 0)
        averageSuccess = 0
        resourceId = ""
    }
    
    public func updateWithConfiguration(_ configuration: EntityConfiguration) {
        guard let configuration = configuration as? ActivityConfiguration else {
            fatalError("Wrong configuration")
        }
        
        name = configuration.name
        type = NSNumber(value: configuration.type)
        notifications = configuration.notifications as NSNumber
        days = daysWithNumbers(configuration.days)
        timing = configuration.timing
        stats = configuration.stats
        if resourceId == "" {
            resourceId = configuration.resourceId
        }
    }
    
    public func setParent(_ parent: ManagedObject?) {
        // no parent needed
    }
    
    public func addResult(result: ResultEntity) {
        updateAverageSuccess(result)
        updateTotalTimeSaved(result)
        incrementTotalResultsNumber()
    }
    
    private func updateTotalTimeSaved(_ result: ResultEntity) {
        guard let newSavedTime = result.savedTime else { return }
        let newValue = totalTimeSaved.doubleValue + newSavedTime.doubleValue
        totalTimeSaved = NSNumber(value: newValue)
    }
    
    private func updateAverageSuccess(_ result: ResultEntity) {
        let totalSuccess = averageSuccess.doubleValue * totalResults.doubleValue
        let updatedSuccess = totalSuccess + result.success.doubleValue
        let newAverage = updatedSuccess / (totalResults.doubleValue + 1)
        averageSuccess = NSNumber(value: newAverage)
    }
    
    private func incrementTotalResultsNumber() {
        totalResults = NSNumber(value: totalResults.intValue + 1)
    }

    
    // MARK: - Private
    
    
    
    fileprivate func daysWithNumbers(_ numbers: [Int]) -> [Day] {
        return numbers.map { (number) -> Day in
            return Day(number: number)
        }
    }
}
