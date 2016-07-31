//
//  ClosestActivityDisplay.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 7/31/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import UIKit
import TimeSlowerKit

internal final class ClosestActivityDisplay: UIView {
    
    private struct Constants {
        static let currentStatusCurrentActivity = "Current activity"
        static let currentStatusNextActivity = "Next activity"
        static let timingStatusStartsIn = "starts in"
        static let timingStatusFinishesIn = "finishes in"
    }
    
    @IBOutlet private(set) weak var view: UIView!
    @IBOutlet private(set) weak var titleLabel: UILabel!
    @IBOutlet private(set) weak var nameLabel: UILabel!
    @IBOutlet private(set) weak var statusLabel: UILabel!
    @IBOutlet private(set) weak var timerLabel: UILabel!
    
    private var timer: MZTimerLabel?
    
    // MARK: - Overridden
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupXib()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupXib()
    }
    
    // MARK: - Internal Functions
    
    func setupWithActivity(activity: Activity?) {
        setupLabelsForActivity(activity)
       
        if let activity = activity {
            launchTimerForActivity(activity)
        }
    }
    
    func launchTimerForActivity(activity: Activity) {
        if let timer = timer {
            if !timer.counting {
                setupTimerCountdownForActivity(activity)
            } else {
                restartTimerForActivity(activity)
            }
        } else {
            setupTimerCountdownForActivity(activity)
        }
    }
    
    func restartTimerForActivity(activity: Activity) {
        let timeTillFinalDate = activity.timing!.nextActionTime()
        let timeTillEndOfCountdown = timer?.getTimeRemaining()
        
        if timeTillFinalDate != timeTillEndOfCountdown {
            reloadTimerForActivity(activity)
        }
    }
    
    func setupTimerCountdownForActivity(activity: Activity) {
        timer = MZTimerLabel(label: timerLabel, andTimerType: MZTimerLabelTypeTimer)
        
        if let timer = timer {
            timer.setCountDownToDate(activity.timing!.nextActionTime())
            timer.resetTimerAfterFinish = false
            
            let timerSecondsToSet = activity.timing!.nextActionTime().timeIntervalSinceNow
            timer.timeFormat = (timerSecondsToSet > 60*60) ? "mm:ss:SS" : "HH:mm:ss"
            
            if timerSecondsToSet > 60*60*24 {
                let hours = round((timerSecondsToSet - 60*60) / 60 / 60)
                timer.timeFormat = NSString(format: "%@:mm:ss", hours.format(".0")) as String
            }
            
            timer.start()
        }
    }
    
    func reloadTimerForActivity(activity: Activity) {
        if timer != nil {
            timer?.removeFromSuperview()
            timer = nil
            setupTimerCountdownForActivity(activity)
        }
    }
    
    // MARK: - Private Functions
    
    private func setupXib() {
        NSBundle.mainBundle().loadNibNamed(ClosestActivityDisplay.className, owner: self, options: nil)
        bounds = view.bounds
        addSubview(view)
    }
    
    private func setupLabelsForActivity(activity: Activity?) {
        if let activity = activity {
            nameLabel.text = activity.name!.uppercaseString
            titleLabel.text = activity.isGoingNow() ?
                Constants.currentStatusCurrentActivity : Constants.currentStatusNextActivity
            statusLabel.text = activity.isGoingNow() ?
                Constants.timingStatusFinishesIn : Constants.timingStatusStartsIn
        } else {
            nameLabel.text = "Create an activity first"
            titleLabel.text = ""
            timerLabel.text = ""
        }
    }
}
