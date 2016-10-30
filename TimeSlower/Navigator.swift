//
//  Navigator.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 10/30/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation
import MessageUI

internal struct Navigator {
    
    private let appStoreUrl = "itms://itunes.apple.com/app/id980075267"
    private let feedbackEmail = "feedback@timeslower.com"

    func openAppStorePage() {
        if let appStoreURL = URL(string: appStoreUrl) {
            UIApplication.shared.open(appStoreURL, options: [:], completionHandler: nil)
        }
    }
    
    func mailComposer() -> MFMailComposeViewController? {
        if (MFMailComposeViewController.canSendMail()){
            let emailBody = stringFromDeviceData()
            let composer = MFMailComposeViewController()
            composer.setToRecipients([feedbackEmail])
            composer.setMessageBody(emailBody, isHTML: true)
            return composer
        }
        
        return nil
    }
    
    private func stringFromDeviceData() -> String {
        var appVersion = ""
        if let unwrappedAppVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            appVersion = "App Version: " + unwrappedAppVersion
        }
        
        let OSVersion = "iOS Version: " + UIDevice.current.systemVersion
        let phoneModel = "Device: " + UIDevice.current.model
        
        let body = "<br/><br/><br/><br/><br/><br/>"
            + "\(appVersion)<br/>\(OSVersion)<br/>\(phoneModel)"
        return body
    }
    
}

