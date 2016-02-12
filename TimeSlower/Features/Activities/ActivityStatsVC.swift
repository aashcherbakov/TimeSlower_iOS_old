//
//  ActivityStatsVC.swift
//  TimeSlower2
//
//  Created by Aleksander Shcherbakov on 5/12/15.
//  Copyright (c) 2015 1lastDay. All rights reserved.
//

import UIKit
import TimeSlowerKit

class ActivityStatsVC: ActivityStatsVCConstraints {
    
    struct Constants {
        static let startButtonTitle = "START NOW"
        static let finishButtonTitle = "FINISH NOW"
    }

    @IBOutlet weak var activityNameLabel: UILabel!
    @IBOutlet weak var activityBasisLabel: UILabel!
    @IBOutlet weak var timerStatusLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var successLabel: UILabel!
    @IBOutlet weak var flowControlButton: UIButton!
    @IBOutlet weak var chartView: ChartView!
    @IBOutlet weak var circleProgress: CircleProgress!
    
    var activity: Activity!
    var timer: MZTimerLabel!
    var lastWeekDayNames = [String]()
    var lastWeekResultValues = [Double]()
    
    //MARK: - LIFECYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(animated: Bool) {
        if activity != nil {
            launchTimer()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        drawProgressView()
    }
    
    func setup() {
        activityNameLabel.text = activity.name
        activityBasisLabel.text = activity.activityBasisDescription()
        timerStatusLabel.text = (activity.isGoingNow()) ? "finishes in" : "starts in"
        
        let format = ".0"
        successLabel.text = "\(activity.stats.averageSuccess.doubleValue.format(format))"
        setupCircleProgress()
        launchTimer()
        defineStartOrFinishButtonTitle()
    }
    
    func setupCircleProgress() {
        circleProgress.progress = activity.stats.averageSuccess.doubleValue
        circleProgress.progressBarWidth = 14
        circleProgress.progressColor = UIColor.purpleRed()
    }
    
    //MARK: - ACTION
    
    @IBAction func onBackButton(sender: UIButton) {
        if let navController = navigationController {
            navController.popViewControllerAnimated(true)
        } else {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    @IBAction func startOrFinishButtonPressed(sender: UIButton) {
        if sender.titleLabel?.text == Constants.startButtonTitle {
            activity.startActivity()
            scheduleFinishTimerForActivity()
            clearTimer()
            setupTimerCountdown()
        } else if sender.titleLabel?.text == Constants.finishButtonTitle {
            activity.finishWithResult()
            activity.deleteNonStandardNotifications()
            clearTimer()
            setup()
            drawProgressView()
        }
         // it's not enought only to delete it in next method to fully restart
        defineStartOrFinishButtonTitle()
    }
    
    func scheduleFinishTimerForActivity() {
        if activity.isRoutine() {
            activity.scheduleFinishTimerNotification()
        } else {
            activity.scheduleLastCallTimerNotification()
        }
    }
    
    func defineStartOrFinishButtonTitle() {
        if !activity.isDoneForToday() {
            let buttonTitle = activity.isGoingNow() ? Constants.finishButtonTitle : Constants.startButtonTitle
            flowControlButton.setTitle(buttonTitle, forState: .Normal)
            flowControlButton.alpha = 1.0
            flowControlButton.userInteractionEnabled = true
        } else {
            flowControlButton.alpha = 0.0
            flowControlButton.userInteractionEnabled = false
        }
    }

    // MARK: - TIMER
    
    func launchTimer() {
        if timer != nil {
            if !timer.counting {
                setupTimerCountdown()
            } else {
                restartTimerIfActivityChanged()
            }
        } else {
            setupTimerCountdown()
        }
    }
    
    func setupTimerCountdown() {
        if timer != nil {
            timer.removeFromSuperview()
            timer = nil
        }
        timer = MZTimerLabel(label: timerLabel, andTimerType: MZTimerLabelTypeTimer)
        timer.setupStandardTimerForActivity(activity)
    }
    
    func restartTimerIfActivityChanged() {
        let intervalTillAction = round(activity.timing.nextActionTime().timeIntervalSinceNow)
        let intervalFromTimer = round(timer.getTimeRemaining())
        if intervalTillAction != intervalFromTimer {
            reloadTimer()
        }
    }
    
    func reloadTimer() {
        if timer != nil {
            timer.removeFromSuperview()
            timer = nil
            setupTimerCountdown()
        }
    }
    
    func clearTimer() {
        timer.pause()
        timer = nil
    }
    
    //MARK: - GRAPH
    
    func drawProgressView() {
        let lastResults = activity.lastWeekResults()
        
        if lastResults.count > 0 {
            setValuesAndLabelsForGraph(lastResults)
            chartView.strokeChart()
        }
    }
    
    
    func setValuesAndLabelsForGraph(lastResults: [DayResults]) {
        for result in lastResults {
            lastWeekDayNames.append(result.shortDayNameForDate())
            lastWeekResultValues.append(result.daySuccess())
        }
        
        addMissingResultsValuesAndLabels(lastResults)
        
        chartView.values = lastWeekResultValues
        chartView.lastWeekDaynames = lastWeekDayNames
    }
    
    func addMissingResultsValuesAndLabels(lastResults: [DayResults]) {
        if lastResults.count < 7 {
            let vacantDaysLeft = 7 - lastWeekResultValues.count
            for var i = 0; i < (7 - lastResults.count); i++ {
                lastWeekResultValues.insert(0.0, atIndex: 0)
            }
            
            let lastDay = DayResults.standardDateFormatter().dateFromString(lastResults.last!.date)
            let components = NSCalendar.currentCalendar().components([.Year, .Month, .Day], fromDate: lastDay!)
            for var i = 0; i < vacantDaysLeft; i++ {
                components.day--
                let nextDate = NSCalendar.currentCalendar().dateFromComponents(components)
                lastWeekDayNames.insert(LazyCalendar.shortDayNameForDate(nextDate!), atIndex: 0)
            }
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EditActivity" {
            if let vc = segue.destinationViewController as? EditActivityVC {
                vc.activity = self.activity
            }
        }
    }
    

}
