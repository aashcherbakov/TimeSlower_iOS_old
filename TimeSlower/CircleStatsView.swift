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
    
    @IBOutlet fileprivate(set) weak var view: UIView!
    @IBOutlet fileprivate(set) weak var routinesCurcle: CircleProgress!
    @IBOutlet fileprivate(set) weak var routineProgressLabel: UILabel!
    @IBOutlet fileprivate(set) weak var routinesTargetLabel: UILabel!
    @IBOutlet private(set) weak var successLabel: UILabel!
    
    // MARK: - Overridden
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupXib()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupXib()
    }
    
    func displayProgress(progress: RoutineProgress) {
        routinesCurcle.updateProgress(CGFloat(progress.success / 100))
        setupCircleDesign()
        displayProgressNumbers(progress: progress)
    }
    
    // MARK: - Private Functions
    
    fileprivate func setupXib() {
        Bundle.main.loadNibNamed(CircleStatsView.className, owner: self, options: nil)
        bounds = view.bounds
        addSubview(view)
    }
    
    fileprivate func setupCircleDesign() {
        routinesCurcle.progressTintColor = UIColor.purpleRed()
    }
    
    private func displayProgressNumbers(progress: RoutineProgress) {
        routineProgressLabel.text = "\(progress.savedTime)"
        routinesTargetLabel.text = "\(progress.plannedTime)"
        successLabel.text = "\(progress.success)"
    }
    
    fileprivate func setupLabels(_ factTiming: SummTiming, plannedTiming: SummTiming) {
        let format = ".0"

        routineProgressLabel.text = "\(factTiming.0.format(format))"
        routinesTargetLabel.text = "\(plannedTiming.0.format(format))"
    }

    
    fileprivate func setupProgress(_ fact: Double, planned: Double, activityType: ActivityType) {
        var result: Double = 0
        if planned > 0 {
            result = fact * 100 / planned
        }
        
        circleForActivityType(activityType).updateProgress(CGFloat(result))
    }
    
    fileprivate func circleForActivityType(_ type: ActivityType) -> CircleProgress {
        return routinesCurcle
    }
}

