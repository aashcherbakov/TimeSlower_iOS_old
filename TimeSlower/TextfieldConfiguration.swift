//
//  TextfieldConfiguration.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 6/11/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation

/**
 *  Protocol that describes configuration for TextfieldView setup
 */
protocol TextfieldConfiguration {
    var placeholder: String { get }
    var textFieldInteractionEnabled: Bool { get }
    var iconHighlighted: UIImage? { get }
    var icon: UIImage? { get }
}

/**
 *  Configuration for TextfiledView to display Name
 */
struct NameTextfield: TextfieldConfiguration {
    var placeholder: String = "Activity name"
    var iconHighlighted: UIImage? = UIImage(named: "activityNameIconBlack")
    var icon: UIImage? = UIImage(named: "activityNameIcon")
    var textFieldInteractionEnabled: Bool = true
}

/**
 *  Configuration for TextfiledView to display Basis
 */
struct BasisTextfield: TextfieldConfiguration {
    var placeholder: String = "Basis"
    var iconHighlighted: UIImage? = UIImage(named: "birthdayIconBlack")
    var icon: UIImage? = UIImage(named: "birthdayIcon")
    var textFieldInteractionEnabled: Bool = false
}

/**
 *  Configuration for TextfiledView to display Start time
 */
struct StartTimeTextfield: TextfieldConfiguration {
    var placeholder: String = "Start time"
    var iconHighlighted: UIImage? = UIImage(named: "startTimeIconBlack")
    var icon: UIImage? = UIImage(named: "startTimeIcon")
    var textFieldInteractionEnabled: Bool = false
}

/**
 *  Configuration for TextfiledView to display Duration
 */
struct DurationTextfield: TextfieldConfiguration {
    var placeholder: String = "Duration"
    var iconHighlighted: UIImage? = UIImage(named: "durationIconBlack")
    var icon: UIImage? = UIImage(named: "durationIcon")
    var textFieldInteractionEnabled: Bool = false
}

/**
 *  Configuration for TextfiledView to display Notification
 */
struct NotificationsTextfield: TextfieldConfiguration {
    var placeholder: String = "Notifications"
    var iconHighlighted: UIImage? = UIImage(named: "notificationIconBlack")
    var icon: UIImage? = UIImage(named: "notificationIcon")
    var textFieldInteractionEnabled: Bool = false
}