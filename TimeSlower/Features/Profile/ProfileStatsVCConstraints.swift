//
//  ProfileStatsVCConstraints.swift
//  TimeSlower2
//
//  Created by Oleksandr Shcherbakov on 7/27/15.
//  Copyright (c) 2015 1lastDay. All rights reserved.
//

import UIKit

class ProfileStatsVCConstraints: UIViewController {

    struct Constants {
        static let lifetimeBalanceScale: CGFloat = 0.17
        static let circlesViewScale: CGFloat = 0.22
        static let buttonOffsetScale: CGFloat = 0.08
        static let redBackgroundScale: CGFloat = 0.68
        static let innerClockBlockScale: CGFloat = 0.17
    }
    
    @IBOutlet weak var lifetimeBalanceHeight: NSLayoutConstraint!
    @IBOutlet weak var circlesViewHeight: NSLayoutConstraint!
    @IBOutlet weak var buttonVerticalOffset: NSLayoutConstraint!
    @IBOutlet weak var redBackgroundHeight: NSLayoutConstraint! // from total height
    @IBOutlet weak var innerBlockHeight: NSLayoutConstraint!
    
    
    @IBOutlet weak var newActivityButton: UIButton!

    override func updateViewConstraints() {
        super.updateViewConstraints()
        setupDefaultConstraints()
        customizeNewActivityButton()
    }
    
    func setupDefaultConstraints() {
        lifetimeBalanceHeight.constant = kUsableViewHeight * Constants.lifetimeBalanceScale
        circlesViewHeight.constant = kUsableViewHeight * Constants.circlesViewScale
        buttonVerticalOffset.constant = kUsableViewHeight * Constants.buttonOffsetScale
        redBackgroundHeight.constant = UIScreen.mainScreen().bounds.height * Constants.redBackgroundScale
        innerBlockHeight.constant = kUsableViewHeight * Constants.innerClockBlockScale
    }
    
    func customizeNewActivityButton() {
        newActivityButton.layer.cornerRadius = newActivityButton.bounds.height / 2
    }
}
