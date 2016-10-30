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
    
    /// Schedules notification for activity of specified type
    ///
    /// - parameter activity:         Activity
    /// - parameter notificationType: NotificationType
    func scheduleForActivity(activity: Activity, notificationType: NotificationType, completionHandler: (() -> ())? = nil) {
        let requests = NotificationFactory().notificationRequests(forType: notificationType, activity: activity)
        
        for request in requests {
            scheduleWithRequest(request: request, completionHandler: completionHandler)
        }
    }
    
    func cancelNotification(forActivity activity: Activity, notificationType: NotificationType) {
        let identifiers = identifiersForActivity(activity: activity, notificationType: notificationType)
        notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
        print("Canceled request for identifiers: \(identifiers)")
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
            if let error = error {
                print("Uh oh! Error with notification scheduler: \(error)")
            }
            
            completion(success)
        }
    }
    
    private func addRequest(request: UNNotificationRequest, completionHandler: (() -> ())? = nil) {
        notificationCenter.add(request) { (error) in
            UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: { (requests) in
                print("Total requests: \(requests.count)")
            })
            
            if let error = error {
                print("Uh oh! Error with notification scheduler: \(error)")
            }
            
            print("Successfully added new notification request: \(request)")
            completionHandler?()
        }
    }
    
    private func identifiersForActivity(activity: Activity, notificationType: NotificationType) -> [String] {
        var identifiers = [String]()
        switch notificationType {
        case .Start:
            for weekday in activity.days {
                let identifier = "\(activity.resourceId)+\(weekday.shortName)"
                identifiers.append(identifier)
            }
        default:
            let finishIdentifer = "\(activity.resourceId)+finish"
            identifiers.append(finishIdentifer)
        }
        
        return identifiers
    }
}
