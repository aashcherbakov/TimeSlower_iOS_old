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
    fileprivate let scheduler = ActivityScheduler()
    fileprivate let dataStore = DataStore()
    
    fileprivate struct Constants {
        // Actions
        static let finishActionTitle = "Finish now"
        static let finishActionIdentifier = "finishNow"
        static let finishCancelTitle = "Not now"
        static let finishCancelIdentifier = "notNow"
        
        // Category
        static let finishCategory = "finishCategory"
    }
    
    func registerNotificationCategories() {
        let finish = finishCategory()
        notificationCenter.setNotificationCategories([finish])
    }
    
    func categoryIdentifierForType(notificationType: NotificationType) -> String {
        return Constants.finishCategory
    }
    
    private func finishCategory() -> UNNotificationCategory {
        let finishAction = UNNotificationAction(identifier: Constants.finishActionIdentifier, title: Constants.finishActionTitle, options: [])
        let cancelAction = UNNotificationAction(identifier: Constants.finishCancelIdentifier, title: Constants.finishCancelTitle, options: [])
        let category = UNNotificationCategory(identifier: Constants.finishCategory, actions: [finishAction, cancelAction], intentIdentifiers: [], options: [])
        return category
    }
    
    private func activityForId(identifier: String) -> Activity? {
        let activity: Activity? = dataStore.retrieve(identifier)
        return activity
    }
    
    private func finishActivity(withIdentifier identifier: String) {
        if let activity = activityForId(identifier: identifier) {
            let _ = scheduler.finish(activity: activity)
            // TODO: navigate to results page
        }
    }
    
    fileprivate func finishActivityFromResponse(response: UNNotificationResponse) {
        let userInfo = response.notification.request.content.userInfo
        if let resourceId = userInfo[kActivityResourceId] as? String {
            finishActivity(withIdentifier: resourceId)
        }
    }
    
}

extension NotificationResponder: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        if response.actionIdentifier == Constants.finishActionIdentifier {
            finishActivityFromResponse(response: response)
        }
        
    }

}
