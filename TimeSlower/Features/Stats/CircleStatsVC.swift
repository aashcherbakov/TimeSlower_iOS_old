//
//  CircleStatsVC.swift
//  TimeSlower2
//
//  Created by Aleksander Shcherbakov on 7/14/15.
//  Copyright (c) 2015 1lastDay. All rights reserved.
//

import UIKit
import TimeSlowerKit

protocol CircleStatsDelegate {
    func pageControllerDidChangeToPage(index: Int)
}

class CircleStatsVC: UIViewController {
    
    struct Constants {
        static let circleBoldnessScele: CGFloat = 0.06
        static let betweenCirclesScale: CGFloat = 0.07
        static let circleViewHeightScale: CGFloat = 0.7
        static let topOffsetScale: CGFloat = 0.04
    }

    var delegate: CircleStatsDelegate!
    var profile: Profile!
    var period: PastPeriod!
    var pageIndex: Int!
    
    @IBOutlet weak var circleProgress: CircleProgress! {
        didSet {
        }
    }
    @IBOutlet weak var innerCircle: CircleProgress! {
        didSet {
            innerCircle.progressColor = UIColor(red: 255/255, green: 136/255, blue: 104/255, alpha: 1)
        }
    }
    @IBOutlet weak var savedTimeLabel: UILabel!
    @IBOutlet weak var usedTimeLabel: UILabel!
    @IBOutlet weak var plannedToSaveLabel: UILabel!
    @IBOutlet weak var plannedToUseLabel: UILabel!
    
    @IBOutlet weak var circleViewHeight: NSLayoutConstraint!
    @IBOutlet weak var topOffset: NSLayoutConstraint!
    
    @IBOutlet weak var innerOffsetTop: NSLayoutConstraint!
    @IBOutlet weak var innerOffsetLow: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLabels()
        circleProgress.progressBarWidth = circleProgress.bounds.height * Constants.circleBoldnessScele
        innerCircle.progressBarWidth = circleProgress.bounds.height * Constants.circleBoldnessScele

        circleProgress.setProgress(0.7, animated: true)
        innerCircle.setProgress(0.3, animated: true)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        delegate.pageControllerDidChangeToPage(pageIndex)
    }
        
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        circleViewHeight.constant = view.bounds.height * Constants.circleViewHeightScale
        topOffset.constant = view.bounds.height * Constants.topOffsetScale
        innerOffsetLow.constant = view.bounds.height * Constants.betweenCirclesScale
        innerOffsetTop.constant = view.bounds.height * Constants.betweenCirclesScale
    }
    
    
    func setupLabels() {
        
        let factTiming = profile.factTimingForPeriod(period)
        let plannedTiming = profile.plannedTimingInPeriod(period, sinceDate: NSDate())
        let format = ".0"
        
        savedTimeLabel.text = "\(factTiming!.0.format(format))"
        usedTimeLabel.text = "\(factTiming!.1.format(format))"
        plannedToSaveLabel.text = "\(plannedTiming!.0.format(format))"
        plannedToUseLabel.text = "\(plannedTiming!.1.format(format))"
        
    }
}
