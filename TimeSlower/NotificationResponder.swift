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
    
    private let notificationCenter = UNUserNotificationCenter.current()
    private let notificationScheduler = NotificationScheduler()
    fileprivate let scheduler = ActivityScheduler()
    fileprivate let dataStore = DataStore()
    
    func registerNotificationCategories() {
        let finish = finishCategory()
        let start = startCategory()
        notificationCenter.setNotificationCategories([finish, start])
    }
    
    // MARK: - Private
    
    private func finishCategory() -> UNNotificationCategory {
        let finishAction = UNNotificationAction(identifier: kFinishActionIdentifier, title: kFinishActionTitle, options: [])
        let cancelAction = defaultCancelAction()
        let category = UNNotificationCategory(identifier: kFinishCategoryId, actions: [finishAction, cancelAction], intentIdentifiers: [], options: [])
        return category
    }
    
    private func startCategory() -> UNNotificationCategory {
        let startAction = UNNotificationAction(identifier: kStartActionIdentifier, title: kStartActionTitle, options: [])
        let cancelAction = defaultCancelAction()
        let category = UNNotificationCategory(identifier: kStartCategoryId, actions: [startAction, cancelAction], intentIdentifiers: [], options: [])
        return category
    }
    
    private func defaultCancelAction() -> UNNotificationAction {
        return UNNotificationAction(identifier: kCancelIdentifier, title: kCancelTitle, options: [])
    }
    
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
    
    private func startActivity(withIdentifier identifier: String) {
        if let activity = activityForId(identifier: identifier) {
            let startedActivity = scheduler.start(activity: activity)
            notificationScheduler.scheduleForActivity(activity: startedActivity, notificationType: .Finish)
            // TODO: navigate to results page
        }
    }
    
    fileprivate func finishActivityFromResponse(response: UNNotificationResponse) {
        let userInfo = response.notification.request.content.userInfo
        if let resourceId = userInfo[kActivityResourceId] as? String {
            finishActivity(withIdentifier: resourceId)
        }
    }
    
    fileprivate func startActivityFromResponse(response: UNNotificationResponse) {
        let userInfo = response.notification.request.content.userInfo
        if let resourceId = userInfo[kActivityResourceId] as? String {
            startActivity(withIdentifier: resourceId)
        }
    }
    
}

extension NotificationResponder: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        switch response.actionIdentifier {
        case kFinishActionIdentifier:
            finishActivityFromResponse(response: response)
        case kStartActionIdentifier:
            startActivityFromResponse(response: response)
        default: return
        }
    }

}
