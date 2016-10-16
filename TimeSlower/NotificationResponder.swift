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
    
    func finishCategory() -> UNNotificationCategory {
        let finishAction = UNNotificationAction(identifier: Constants.finishActionIdentifier, title: Constants.finishActionTitle, options: [])
        let cancelAction = UNNotificationAction(identifier: Constants.finishCancelIdentifier, title: Constants.finishCancelTitle, options: [])
        let category = UNNotificationCategory(identifier: Constants.finishCategory, actions: [finishAction, cancelAction], intentIdentifiers: [], options: [])
        return category
    }
    
}

extension NotificationResponder: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        if response.actionIdentifier == Constants.finishActionIdentifier {
            
        }
        
    }
}
