//
//  NotificationHandler.swift
//  TimeSlower2
//
//  Created by Aleksander Shcherbakov on 5/27/15.
//  Copyright (c) 2015 1lastDay. All rights reserved.
//

import Foundation
import TimeSlowerKit

func registerUserNotificationSettings() {
    let startTimerAction = UIMutableUserNotificationAction()
    startTimerAction.identifier = kStartNowButtonAction
    startTimerAction.title = "Start now"
    startTimerAction.activationMode = .foreground
    startTimerAction.isAuthenticationRequired = false
    
    let finishTimerAction = UIMutableUserNotificationAction()
    finishTimerAction.identifier = kFinishNowButtonAction
    finishTimerAction.title = "Finish now"
    finishTimerAction.activationMode = .foreground
    finishTimerAction.isAuthenticationRequired = false
    
    let remindMeTimerAction = UIMutableUserNotificationAction()
    remindMeTimerAction.identifier = kRemindMeButtonAction
    remindMeTimerAction.title = "Remind in..."
    remindMeTimerAction.activationMode = .foreground
    remindMeTimerAction.isAuthenticationRequired = false
    
    let snoozeTimerAction = UIMutableUserNotificationAction()
    snoozeTimerAction.identifier = kSnoozeButtonAction
    snoozeTimerAction.title = "Snooze"
    snoozeTimerAction.activationMode = .foreground
    snoozeTimerAction.isAuthenticationRequired = false
    
    
    let startTimerCategory = UIMutableUserNotificationCategory()
    startTimerCategory.identifier = TimerCategory.StartTimer.rawValue
    startTimerCategory.setActions([startTimerAction, remindMeTimerAction], for: .default)
    
    let finishTimerCategory = UIMutableUserNotificationCategory()
    finishTimerCategory.identifier = TimerCategory.FinishTimer.rawValue
    finishTimerCategory.setActions([finishTimerAction, snoozeTimerAction], for: .default)
    
    let lastCallTimerCategory = UIMutableUserNotificationCategory()
    lastCallTimerCategory.identifier = TimerCategory.LastCallTimer.rawValue
    lastCallTimerCategory.setActions([finishTimerAction], for: .default)
    
    let categories = NSSet(array: [startTimerCategory, finishTimerCategory, lastCallTimerCategory])
    let settings = UIUserNotificationSettings(types: [.alert, .sound], categories: categories as? Set<UIUserNotificationCategory>)
    UIApplication.shared.registerUserNotificationSettings(settings)
}
