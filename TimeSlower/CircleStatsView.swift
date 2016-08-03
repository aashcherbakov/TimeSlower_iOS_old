//
//  CircleStatsView.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 7/31/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import UIKit
import TimeSlowerKit

class CircleStatsView: UIView {
    
    typealias SummTiming = (Double, Double)
    
    @IBOutlet private(set) weak var view: UIView!
    @IBOutlet private(set) weak var goalsCircle: CircleProgress!
    @IBOutlet private(set) weak var routinesCircle: CircleProgress!
    @IBOutlet private(set) weak var routineProgressLabel: UILabel!
    @IBOutlet private(set) weak var routinesTargetLabel: UILabel!
    @IBOutlet private(set) weak var goalsProgressLabel: UILabel!
    @IBOutlet private(set) weak var goalsTargetLabel: UILabel!
    
    // MARK: - Overridden
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupXib()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupXib()
    }
    
    func displayProgressForProfile(profile: Profile?) {
        guard let profile = profile else {
            fatalError("No profile found, database programming error")
        }
        
        setupCircleDesign()
        
        
        setupDataForProfile(profile)
    }
    
    // MARK: - Private Functions
    
    private func setupXib() {
        NSBundle.mainBundle().loadNibNamed(CircleStatsView.className, owner: self, options: nil)
        bounds = view.bounds
        addSubview(view)
    }
    
    private func setupCircleDesign() {
        routinesCircle.progressColor = UIColor(red: 255/255, green: 136/255, blue: 104/255, alpha: 1)
    }
    
    private func setupDataForProfile(profile: Profile) {

        if let
            factTiming = profile.factTimingForPeriod(.Today),
            plannedTiming = profile.plannedTimingInPeriod(.Today, sinceDate: NSDate()) {
            
            setupLabels(factTiming: factTiming, plannedTiming: plannedTiming)
            setupProgress(fact: factTiming.saved, planned: plannedTiming.save, activityType: .Routine)
            setupProgress(fact: factTiming.spent, planned: plannedTiming.spend, activityType: .Goal)
        }
    }
    
    private func setupLabels(factTiming factTiming: SummTiming, plannedTiming: SummTiming) {
        let format = ".0"

        routineProgressLabel.text = "\(factTiming.0.format(format))"
        goalsProgressLabel.text = "\(factTiming.1.format(format))"
        routinesTargetLabel.text = "\(plannedTiming.0.format(format))"
        goalsTargetLabel.text = "\(plannedTiming.1.format(format))"
    }

    
    private func setupProgress(fact fact: Double, planned: Double, activityType: ActivityType) {
        var result: Double = 0
        if planned > 0 {
            result = fact * 100 / planned
        }
        
        circleForActivityType(activityType).setProgress(result, animated: true)
    }
    
    private func circleForActivityType(type: ActivityType) -> CircleProgress {
        switch type {
        case .Routine: return routinesCircle
        case .Goal: return goalsCircle
        }
    }
}

