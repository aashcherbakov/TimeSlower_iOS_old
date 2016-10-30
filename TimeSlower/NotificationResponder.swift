//
//  NotificationResponder.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 10/15/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation
import UserNotifications
import TimeSlowerKit

internal final class NotificationResponder: NSObject {
    
    private let notificationScheduler = NotificationScheduler()
    fileprivate let scheduler = ActivityScheduler()
    fileprivate let dataStore = DataStore()
    
    private func activityForId(identifier: String) -> Activity? {
        let activity: Activity? = dataStore.retrieve(identifier)
        return activity
    }
    
    private func finishActivity(withIdentifier identifier: String) {
        if let activity = activityForId(identifier: identifier) {
            let finishedActivity = scheduler.finish(activity: activity)
            // TODO: navigate to results page
        }
    }
    
    private func startActivity(withIdentifier identifier: String, completionHandler: @escaping () -> ()) {
        if let activity = activityForId(identifier: identifier) {
            let startedActivity = scheduler.start(activity: activity)
            notificationScheduler.scheduleForActivity(activity: startedActivity, notificationType: .Finish, completionHandler: completionHandler)
            // TODO: navigate to results page
        }
    }
    
    fileprivate func finishActivityFromResponse(response: UNNotificationResponse) {
        let userInfo = response.notification.request.content.userInfo
        if let resourceId = userInfo[kActivityResourceId] as? String {
            finishActivity(withIdentifier: resourceId)
        }
    }
    
    fileprivate func startActivityFromResponse(response: UNNotificationResponse, completionHandler: @escaping () -> ()) {
        let userInfo = response.notification.request.content.userInfo
        if let resourceId = userInfo[kActivityResourceId] as? String {
            startActivity(withIdentifier: resourceId, completionHandler: completionHandler)
        }
    }
    
}

extension NotificationResponder: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        switch response.actionIdentifier {
        case kFinishActionIdentifier:
            finishActivityFromResponse(response: response)
            completionHandler()
        case kStartActionIdentifier:
            startActivityFromResponse(response: response, completionHandler: completionHandler)
        default:
            completionHandler()
            return
        }

    }

}
