//
//  NotificationScheduler.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 10/15/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation
import UserNotifications
import TimeSlowerKit

internal class NotificationScheduler {
    
    private let notificationCenter = UNUserNotificationCenter.current()
    private let userDefaults = UserDefaultsStore()
    private let notificationFactory = NotificationFactory()
    
    /// Schedules notification for activity of specified type
    ///
    /// - parameter activity:         Activity
    /// - parameter notificationType: NotificationType
    func scheduleForActivity(
        activity: Activity,
        notificationType: NotificationType,
        completionHandler: (() -> ())? = nil) {
        
        let requests = notificationFactory.request(for: notificationType, activity: activity)
        
        for request in requests {
            scheduleWithRequest(request: request, completionHandler: completionHandler)
        }
    }
    
    func cancelNotification(forActivity activity: Activity, notificationType: NotificationType) {
        let identifiers = identifiersForActivity(activity: activity, notificationType: notificationType)
        notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    func cancelAllNotifications() {
        if !userDefaults.hasScheduledLocalNotifications() {
            notificationCenter.removeAllDeliveredNotifications()
            notificationCenter.removeAllPendingNotificationRequests()
        }
    }
    
    // MARK: - Private

    private func scheduleWithRequest(request: UNNotificationRequest, completionHandler: (() -> ())? = nil) {
        notificationCenter.getNotificationSettings { (settings) in
            if settings.authorizationStatus != .authorized {
                self.askForPermissionAndAdd(request: request, completionHandler: completionHandler)
            } else {
                self.addRequest(request: request, completionHandler: completionHandler)
            }
        }
    }
    
    private func askForPermissionAndAdd(request: UNNotificationRequest, completionHandler: (() -> ())? = nil) {
        requestUserPermission { (success) in
            if success {
                self.addRequest(request: request, completionHandler: completionHandler)
            } else {
                // TODO: prompt alert for user that app can't work without notifications
            }
        }
    }
    
    private func requestUserPermission(completion: @escaping (Bool) -> ()) {
        notificationCenter.requestAuthorization(options: [.alert, .sound]) { (success, error) in
            
            if let error = error { print("Uh oh! Error with notification scheduler: \(error)") }
            completion(success)
        }
    }
    
    private func addRequest(request: UNNotificationRequest, completionHandler: (() -> ())? = nil) {
        notificationCenter.add(request) { [weak self] (error) in
            
            if let error = error { print("Uh oh! Error with notification scheduler: \(error)") }
            self?.userDefaults.setHasScheduledLocalNotifications(value: true)
            completionHandler?()
        }
    }
    
    private func identifiersForActivity(activity: Activity, notificationType: NotificationType) -> [String] {
        var identifiers = [String]()
        switch notificationType {
        case .start:
            for weekday in activity.days {
                let identifier = "\(activity.resourceId)+\(weekday.shortName)"
                identifiers.append(identifier)
            }
        case .finish:
            let finishIdentifer = "\(activity.resourceId)+finish"
            identifiers.append(finishIdentifer)
        }
        
        return identifiers
    }
    
}
