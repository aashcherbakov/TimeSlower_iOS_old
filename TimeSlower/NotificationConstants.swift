//
//  NotificationConstants.swift
//  TimeSlower
//
//  Created by Alexander Shcherbakov on 10/28/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation

// Actions
let kFinishActionTitle = "Finish Now"
let kFinishActionIdentifier = "finishNow"

let kCancelTitle = "Not now"
let kCancelIdentifier = "notNow"

let kStartActionTitle = "Start Now"
let kStartActionIdentifier = "startNow"

// Category
let kFinishCategoryId = "finishCategory"
let kStartCategoryId = "startCategory"


internal enum NotificationCategory: String {
    case Finish = "finishCategory"
    case Start = "startCategory"
    
    init(withNotificationType type: NotificationType) {
        switch type {
        case .Start:
            self = .Start
        default:
            self = .Finish
        }
    }
}
