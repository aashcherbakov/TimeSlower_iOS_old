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
    var shouldShowDefaultButton: Bool { get }
    var defaultValue: String? { get }
}

extension TextfieldConfiguration {
    var shouldShowDefaultButton: Bool {
        return false
    }
    
    var defaultValue: String? {
        return nil
    }
}

// MARK: - Activity

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

// MARK: - Profile

struct ProfileNameTextfield: TextfieldConfiguration {
    var placeholder: String = "Your name"
    var iconHighlighted: UIImage? = UIImage(named: "nameIconBlack")
    var icon: UIImage? = UIImage(named: "nameIcon")
    var textFieldInteractionEnabled: Bool = true
}

struct ProfileBirthdayTextfield: TextfieldConfiguration {
    var placeholder: String = "Date of birth"
    var iconHighlighted: UIImage? = UIImage(named: "birthdayIconBlack")
    var icon: UIImage? = UIImage(named: "birthdayIcon")
    var textFieldInteractionEnabled: Bool = false
    var shouldShowDefaultButton: Bool = true
    var defaultValue: String? = "Mar 28, 1987"
}

struct ProfileCountryTextfield: TextfieldConfiguration {
    var placeholder: String = "Country you live in"
    var iconHighlighted: UIImage? = UIImage(named: "countryIconBlack")
    var icon: UIImage? = UIImage(named: "countryIcon")
    var textFieldInteractionEnabled: Bool = false
    var shouldShowDefaultButton: Bool = true
    var defaultValue: String = "United States"
}
