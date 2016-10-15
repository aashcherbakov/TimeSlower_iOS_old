//
//  MainScreenVCConstraints.swift
//  TimeSlower2
//
//  Created by Aleksander Shcherbakov on 7/13/15.
//  Copyright (c) 2015 1lastDay. All rights reserved.
//

import UIKit

class MainScreenVCConstraints: UIViewController {

    struct Constants {
        static let circleViewScale: CGFloat = 0.50
        static let legendViewScale: CGFloat = 0.12
        static let offsetFromLegendScale: CGFloat = 0.05
        static let compoundWhiteViewHeightScale: CGFloat = 0.67
        static let nextActivityBlockScale: CGFloat = 0.2
    }
    
    @IBOutlet weak var legendViewHeight: NSLayoutConstraint!
    @IBOutlet weak var compoundWhiteViewHeight: NSLayoutConstraint!
    @IBOutlet weak var nextActivityBlockHeight: NSLayoutConstraint!
    @IBOutlet weak var startNowButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var startNowButtonHeight: NSLayoutConstraint!
    @IBOutlet weak var offsetFromLegend: NSLayoutConstraint!
    @IBOutlet weak var buttonDownOffset: NSLayoutConstraint!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupPageDotsColors()
    }
    
    func setupPageDotsColors() {
        let pageController = UIPageControl.appearance()
        pageController.pageIndicatorTintColor = UIColor.lightGray()
        pageController.currentPageIndicatorTintColor = UIColor.purpleRed()
        pageController.backgroundColor = UIColor.clear
    }

    override func updateViewConstraints() {
        super.updateViewConstraints()
        setupDefaultConstraints()
    }
    
    func setupDefaultConstraints() {        
        legendViewHeight.constant = kUsableViewHeight * Constants.legendViewScale
        offsetFromLegend.constant = kUsableViewHeight * Constants.offsetFromLegendScale
        compoundWhiteViewHeight.constant = kUsableViewHeight * Constants.compoundWhiteViewHeightScale
        nextActivityBlockHeight.constant = kUsableViewHeight * Constants.nextActivityBlockScale
        startNowButtonHeight.constant = kUsableViewHeight * LayoutConstants.buttonHeightScale
        startNowButtonWidth.constant = kUsableViewWidth * LayoutConstants.buttonWidthScale
        buttonDownOffset.constant = kUsableViewHeight * LayoutConstants.buttonDownOffset
    }
}
