//
//  ActivityStatsVCConstraints.swift
//  TimeSlower2
//
//  Created by Oleksandr Shcherbakov on 7/25/15.
//  Copyright (c) 2015 1lastDay. All rights reserved.
//

import UIKit

class ActivityStatsVCConstraints: UIViewController {

    
    struct Constants {
        static let averageSuccessHeightScale: CGFloat = 0.09
        static let circleViewHeightScale: CGFloat = 0.21
        static let graphViewHeightScale: CGFloat = 0.29
        static let statsViewHeightScale: CGFloat = 0.12
        static let backGroungHeightScale: CGFloat = 0.33

    }
    
    @IBOutlet weak var circleViewHeight: NSLayoutConstraint!
    @IBOutlet weak var averageSuccessHeight: NSLayoutConstraint!
    @IBOutlet weak var graphViewHeight: NSLayoutConstraint!
    @IBOutlet weak var statsViewHeight: NSLayoutConstraint!
    @IBOutlet weak var backgroundHeight: NSLayoutConstraint!
    
    @IBOutlet weak var controlFlowButtonOffset: NSLayoutConstraint!
    @IBOutlet weak var controlFlowButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var controlFlowButtonHeight: NSLayoutConstraint!
    
    @IBOutlet weak var controlFlowButton: UIButton!
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        setupDefaultConstraints()
    }
    

    func setupDefaultConstraints() {
        setupBigButtonConstraints()
        shapeBigButton()
        circleViewHeight.constant = kUsableViewHeight * Constants.circleViewHeightScale
        averageSuccessHeight.constant = kUsableViewHeight * Constants.averageSuccessHeightScale
        graphViewHeight.constant = kUsableViewHeight * Constants.graphViewHeightScale
        statsViewHeight.constant = kUsableViewHeight * Constants.statsViewHeightScale
        backgroundHeight.constant = kUsableViewHeight * Constants.backGroungHeightScale
    }
    
    func setupBigButtonConstraints() {
        controlFlowButtonOffset.constant = kUsableViewHeight * LayoutConstants.buttonDownOffset
        controlFlowButtonHeight.constant = kUsableViewHeight * LayoutConstants.buttonHeightScale
        controlFlowButtonWidth.constant = kUsableViewWidth * LayoutConstants.buttonWidthScale
    }
    
    func shapeBigButton() {
        controlFlowButton.layer.cornerRadius = controlFlowButtonHeight.constant / 2
    }
}
