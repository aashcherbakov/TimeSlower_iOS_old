//
//  ActivityManage.swift
//  TimeSlower2
//
//  Created by Aleksander Shcherbakov on 5/2/15.
//  Copyright (c) 2015 1lastDay. All rights reserved.
//

import Foundation
import CoreData

enum ActivityType: Int {
    case Routine
    case Goal
}

enum ActivityBasis: Int {
    case Daily
    case Workdays
    case Weekends
}

extension Activity {
    

    
    class func newActivityForProfile(userProfile: Profile, ofType: ActivityType) -> Activity {
        let entity = NSEntityDescription.entityForName("Activity", inManagedObjectContext: userProfile.managedObjectContext!)
        let activity = Activity(entity: entity!, insertIntoManagedObjectContext: userProfile.managedObjectContext)
        activity.type = activity.typeWithEnum(ofType)
        activity.profile = userProfile
        activity.stats = Stats.newStatsForActivity(activity: activity)
        activity.timing = Timing.newTimingForActivity(activity: activity)
        
        var error: NSError?
        if !userProfile.managedObjectContext!.save(&error) { print("Could not save: \(error)") }
        
        print("New activity created: \(activity)")
        return activity
    }
    
    func typeWithEnum(type: ActivityType) -> NSNumber {
        return NSNumber(integer: type.rawValue)
    }
    
    func basisWithEnum(basis: ActivityBasis) -> NSNumber {
        return NSNumber(integer: basis.rawValue)
    }
    
    //WARNING: workaround with passing uriData may be bad
    func userInfoForActivity() -> [NSObject : AnyObject] {
        let uri = objectID.URIRepresentation()
        let uriData = NSKeyedArchiver.archivedDataWithRootObject(uri)
        return ["Name":name, "Activity":uriData]
    }
    
    //MARK: - Property convenience
    
    func isRoutine() -> Bool {
        return (type.integerValue == 0) ? true : false
    }
    
    func activityBasis() -> ActivityBasis {
        return ActivityBasis(rawValue: self.basis.integerValue)!
    }
    
    func activityBasisDescription() -> String {
        var stringBasis = ""
        switch activityBasis() {
        case .Daily: stringBasis = "Daily"
        case .Workdays: stringBasis = "Workdays"
        case .Weekends: stringBasis = "Weekends"
        }
        return stringBasis
    }
    
    func activityType() -> ActivityType {
        return ActivityType(rawValue: self.type.integerValue)!
    }
    
    func isDoneForToday() -> Bool {
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeStyle = .NoStyle
        dateFormatter.dateStyle = .ShortStyle
        let todaysDate = dateFormatter.stringFromDate(NSDate())
        
        let resultsForDate = fetchResultsWithDate(todaysDate)
        //println("Results for date \(todaysDate) for activity \(name): \(resultsForDate?.count)")
        
        if let results = resultsForDate {
            if results.count > 0 {
                return true
            }
        }
        return false
    }
    
    func fetchResultsWithDate(date: String) -> [DayResults]? {
        let fetchRequest = NSFetchRequest(entityName: "DayResults")
        let activityNamePredicate = NSPredicate(format: "activity.name == %@", name)
        let dayOfResultPredicate = NSPredicate(format: "date == %@", date)
        let compoundPredicate = NSCompoundPredicate.andPredicateWithSubpredicates([activityNamePredicate, dayOfResultPredicate])
        fetchRequest.predicate = compoundPredicate
        
        var error: NSError?
        var results = managedObjectContext!.executeFetchRequest(fetchRequest, error: &error) as? [DayResults]
        
        if let readyResults = results {
            return readyResults
        } else {
            print("Error when fetching DayResults: \(error!)")
        }
        return nil
    }
    
    func isPassedDueForToday() -> Bool {
        let nowDate = NSDate(), finishTime = timing.updatedFinishTime()
        let earlierDate = nowDate.earlierDate(finishTime)
        return (earlierDate == finishTime) ? true : false
    }
    
    func isGoingNow() -> Bool {
        let startTime = updatedStartTime(), finishTime = updatedFinishTime()
        
        if finishTime.earlierDate(NSDate()) == finishTime {
            return false
        } else if isDoneForToday() {
            return false
        }
        
        if startTime.earlierDate(NSDate()) == startTime
            && finishTime.laterDate(NSDate()) == finishTime {
            return true
        }
        return false
    }
    
    func isManuallyStarted() -> Bool { return timing.manuallyStarted != nil }
    func updatedStartTime() -> NSDate { return timing.updatedStartTime() }
    func updatedFinishTime() -> NSDate { return timing.updatedFinishTime() }
    func updatedAlarmTime() -> NSDate { return timing.updatedAlarmTime() }
    
    
    func lastWeekResults() -> [DayResults] {
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true, selector: "compareDateRepresentationOfString:")
        var sortedArray = results.sortedArrayUsingDescriptors([sortDescriptor])
        if sortedArray.count > 7 {
            if sortedArray.count > 0 {
                let lastResultsNumber = (sortedArray.count < 7) ? sortedArray.count : 7
                sortedArray.removeRange(0..<(sortedArray.count - lastResultsNumber))
            }
        }
        return sortedArray as! [DayResults]
    }
    
    func compareBasedOnNextActionTime(otherActivity: Activity) -> NSComparisonResult {
        let thisDate = timing.nextActionTime()
        let otherDate = otherActivity.timing.nextActionTime()
        return thisDate.compare(otherDate)
    }
}


extension NSString {
    func compareDateRepresentationOfString(otherString: String) -> NSComparisonResult {
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeStyle = .NoStyle
        dateFormatter.dateStyle = .ShortStyle
        
        let firstDate = dateFormatter.dateFromString(self as String)
        let secondDate = dateFormatter.dateFromString(otherString)
        return firstDate!.compare(secondDate!)
    }
}

extension NSManagedObjectContext {
    func objectWithURI(uri: NSURL) -> NSManagedObject? {
        let objectID = persistentStoreCoordinator?.managedObjectIDForURIRepresentation(uri)
        if objectID == nil { return nil }
        
        let objectForID = objectWithID(objectID!)
        if !objectForID.fault { return objectForID }
        
        let request = NSFetchRequest()
        request.entity = objectID?.entity
        
        let predicate = NSComparisonPredicate(
            leftExpression: NSExpression.expressionForEvaluatedObject(),
            rightExpression: NSExpression(forConstantValue: objectForID),
            modifier: .DirectPredicateModifier,
            type: .EqualToPredicateOperatorType,
            options: nil)
        request.predicate = predicate
        
        let results = executeFetchRequest(request, error: nil)
        if results?.count > 0 {
            return results?.first as? NSManagedObject
        }
        return nil
    }
}