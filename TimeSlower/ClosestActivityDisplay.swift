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
    
    fileprivate struct Constants {
        static let currentStatusCurrentActivity = "Current activity"
        static let currentStatusNextActivity = "Next activity"
        static let timingStatusStartsIn = "starts in"
        static let timingStatusFinishesIn = "finishes in"
    }
    
    @IBOutlet fileprivate(set) weak var view: UIView!
    @IBOutlet fileprivate(set) weak var titleLabel: UILabel!
    @IBOutlet fileprivate(set) weak var nameLabel: UILabel!
    @IBOutlet fileprivate(set) weak var statusLabel: UILabel!
    @IBOutlet fileprivate(set) weak var timerLabel: UILabel!
    
    fileprivate var timer: MZTimerLabel?
    
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
    
    func setupWithActivity(_ activity: Activity?) {
        launchTimerForActivity(activity)
        setupLabelsForActivity(activity)
    }
    
    func launchTimerForActivity(_ activity: Activity?) {
        guard let activity = activity else {
            return
        }
        
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
    
    func restartTimerForActivity(_ activity: Activity) {
//        let timeTillFinalDate = activity.timing.nextActionTime()
//        let timeTillEndOfCountdown = timer?.getTimeRemaining()
//        
//        if timeTillFinalDate != timeTillEndOfCountdown {
//            reloadTimerForActivity(activity)
//        }
    }
    
    func setupTimerCountdownForActivity(_ activity: Activity) {
        timer = MZTimerLabel(label: timerLabel, andTimerType: MZTimerLabelTypeTimer)
        
        if let timer = timer {
//            timer.setCountDownTo(activity.timing.nextActionTime())
//            timer.resetTimerAfterFinish = false
//            
//            let timerSecondsToSet = activity.timing.nextActionTime().timeIntervalSinceNow
//            timer.timeFormat = (timerSecondsToSet > 60*60) ? "mm:ss:SS" : "HH:mm:ss"
//            
//            if timerSecondsToSet > 60*60*24 {
//                let hours = round((timerSecondsToSet - 60*60) / 60 / 60)
//                timer.timeFormat = NSString(format: "%@:mm:ss", hours.format(".0")) as String
//            }
//            
            timer.start()
        }
    }
    
    func reloadTimerForActivity(_ activity: Activity) {
        if timer != nil {
            timer?.removeFromSuperview()
            timer = nil
            setupTimerCountdownForActivity(activity)
        }
    }
    
    // MARK: - Private Functions
    
    fileprivate func setupXib() {
        Bundle.main.loadNibNamed(ClosestActivityDisplay.className, owner: self, options: nil)
        bounds = view.bounds
        addSubview(view)
    }
    
    fileprivate func setupLabelsForActivity(_ activity: Activity?) {
        if let activity = activity {
            nameLabel.text = activity.name.uppercased()
            titleLabel.text = activity.isGoingNow() ?
                Constants.currentStatusCurrentActivity : Constants.currentStatusNextActivity
            statusLabel.text = activity.isGoingNow() ?
                Constants.timingStatusFinishesIn : Constants.timingStatusStartsIn
        } else {
            nameLabel.text = "No activities for today 😳"
            titleLabel.text = ""
            timerLabel.text = ""
            statusLabel.text = ""
        }
    }
}
