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
    startTimerAction.activationMode = .Foreground
    startTimerAction.authenticationRequired = false
    
    let finishTimerAction = UIMutableUserNotificationAction()
    finishTimerAction.identifier = kFinishNowButtonAction
    finishTimerAction.title = "Finish now"
    finishTimerAction.activationMode = .Foreground
    finishTimerAction.authenticationRequired = false
    
    let remindMeTimerAction = UIMutableUserNotificationAction()
    remindMeTimerAction.identifier = kRemindMeButtonAction
    remindMeTimerAction.title = "Remind in..."
    remindMeTimerAction.activationMode = .Foreground
    remindMeTimerAction.authenticationRequired = false
    
    let snoozeTimerAction = UIMutableUserNotificationAction()
    snoozeTimerAction.identifier = kSnoozeButtonAction
    snoozeTimerAction.title = "Snooze"
    snoozeTimerAction.activationMode = .Foreground
    snoozeTimerAction.authenticationRequired = false
    
    
    let startTimerCategory = UIMutableUserNotificationCategory()
    startTimerCategory.identifier = TimerCategory.StartTimer.rawValue
    startTimerCategory.setActions([startTimerAction, remindMeTimerAction], forContext: .Default)
    
    let finishTimerCategory = UIMutableUserNotificationCategory()
    finishTimerCategory.identifier = TimerCategory.FinishTimer.rawValue
    finishTimerCategory.setActions([finishTimerAction, snoozeTimerAction], forContext: .Default)
    
    let lastCallTimerCategory = UIMutableUserNotificationCategory()
    lastCallTimerCategory.identifier = TimerCategory.LastCallTimer.rawValue
    lastCallTimerCategory.setActions([finishTimerAction], forContext: .Default)
    
    let categories = NSSet(array: [startTimerCategory, finishTimerCategory, lastCallTimerCategory])
    let settings = UIUserNotificationSettings(forTypes: [.Alert, .Sound], categories: categories as? Set<UIUserNotificationCategory>)
    UIApplication.sharedApplication().registerUserNotificationSettings(settings)
}