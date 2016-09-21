////
////  StatsCalculator.swift
////  TimeSlower
////
////  Created by Oleksandr Shcherbakov on 8/28/16.
////  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
////
//
//import CoreData
//
//public struct FactResults {
//    let saved: Double
//    let spent: Double
//    
//    init(saved: Double, spent: Double) {
//        self.saved = saved
//        self.spent = spent
//    }
//}
//
//public struct StatsCalculator {
//    
////    public func factResultsForPeriod(period: PastPeriod, profile: Profile) -> FactResults {
////        
////        var saved = 0.0
////        var spent = 0.0
////        
////        for activity in profile.allActivities() {
////            let results = activity.allResultsPredicateForPeriod(period)
////            for result in re
////        }
////    }
////    
////    
////    /// Returns $0 - saved, $1 - spent
////    public func factTimingForPeriod(period: PastPeriod) -> (saved: Double, spent: Double)? {
////        
////        var summSaved = 0.0
////        var summSpent = 0.0
////        
////        for activity in allActivities() {
////            for result in activity.unitTesting_allResultsForPeriod(period) {
////                if activity.isRoutine() {
////                    summSaved += result.factSavedTime!.doubleValue
////                } else {
////                    summSpent += result.factDuration.doubleValue
////                }
////            }
////        }
////        return (summSaved, summSpent)
////    }
////    
////    /// Returns $0 - saved, $1 - spent in minutes
////    public func plannedTimingInPeriod(period: PastPeriod, sinceDate date: NSDate) -> (save: Double, spend: Double)? {
////        var toSave = 0.0;
////        var toSpend = 0.0;
////        
////        for activity in allActivities() {
////            let numberOfDays = activity.stats.busyDaysForPeriod(period, sinceDate: date)
////            if activity.isRoutine() {
////                toSave += activity.timing.timeToSave.doubleValue * Double(numberOfDays)
////            } else {
////                toSpend += Double(activity.timing.duration.minutes()) * Double(numberOfDays)
////            }
////        }
////        return (abs(toSave), abs(toSpend)) // minutes
////    }
////    
////    public func timeStatsForPeriod(period: PastPeriod) -> DailyStats {
////        let fact = factTimingForPeriod(period)
////        let planned = plannedTimingInPeriod(period, sinceDate: NSDate())
////        return DailyStats(factSaved: fact!.0, factSpent: fact!.1, plannedToSave: planned!.0, plannedToSpend: planned!.1)
////    }
//
//}
//
