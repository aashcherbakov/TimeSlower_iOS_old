//
//  ActivityMotivationVCConstraints.swift
//  TimeSlower2
//
//  Created by Oleksandr Shcherbakov on 7/26/15.
//  Copyright (c) 2015 1lastDay. All rights reserved.
//

import UIKit

class ActivityMotivationVCConstraints: UIViewController {

    struct Constants {
        static let whiteBackHeightScale: CGFloat = 0.21
        static let statsViewOffsetScale: CGFloat = 0.06
        static let statsViewHeightScale: CGFloat = 0.09
        static let descriptionViewHeightScale: CGFloat = 0.18
        static let dotsViewHeightScale: CGFloat = 0.42
    }
    
    @IBOutlet weak var whiteBackHeight: NSLayoutConstraint!
    @IBOutlet weak var statsViewVerticalOffset: NSLayoutConstraint!
    @IBOutlet weak var statsViewHeight: NSLayoutConstraint!
    @IBOutlet weak var descriptionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var dotsViewHeight: NSLayoutConstraint!
    @IBOutlet weak var startTimeCenterOffset: NSLayoutConstraint! // half of screen
    @IBOutlet weak var durationCenterOffset: NSLayoutConstraint! // -startTimeCenterOffset.constant
    
    @IBOutlet weak var buttonBackground: UIView!
    
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        setupDefaultConstraints()
    }
    
    func setupDefaultConstraints() {
        setupButtonBackground()
        whiteBackHeight.constant = kUsableViewHeight * Constants.whiteBackHeightScale
        statsViewVerticalOffset.constant = kUsableViewHeight * Constants.statsViewOffsetScale
        statsViewHeight.constant = kUsableViewHeight * Constants.statsViewHeightScale
        descriptionViewHeight.constant = kUsableViewHeight * Constants.descriptionViewHeightScale
        dotsViewHeight.constant = kUsableViewHeight * Constants.dotsViewHeightScale
        
    }
    
    func setupButtonBackground() {
        buttonBackground.layer.cornerRadius = buttonBackground.frame.height / 2
        buttonBackground.layer.borderColor = UIColor.darkRed().CGColor
        buttonBackground.layer.borderWidth = 1.0
    }

}
