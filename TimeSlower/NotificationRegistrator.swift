//
//  NotificationRegistrator.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 10/29/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation
import UserNotifications

internal struct NotificationRegistrator {
    
    private let notificationCenter = UNUserNotificationCenter.current()

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
    
}
