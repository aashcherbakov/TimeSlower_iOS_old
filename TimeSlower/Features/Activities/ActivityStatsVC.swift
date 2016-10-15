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
    
    override func viewWillAppear(_ animated: Bool) {
        if activity != nil {
            launchTimer()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        drawProgressView()
    }
    
    func setup() {
        activityNameLabel.text = activity.name
//        activityBasisLabel.text = activity.activityBasis().description()
//        timerStatusLabel.text = (activity.isGoingNow()) ? "finishes in" : "starts in"
        
        let format = ".0"
//        successLabel.text = "\(activity.stats.averageSuccess.doubleValue.format(format))"
        setupCircleProgress()
        launchTimer()
        defineStartOrFinishButtonTitle()
    }
    
    func setupCircleProgress() {
//        circleProgress.progress = activity.stats.averageSuccess.doubleValue
//        circleProgress.progressBarWidth = 14
//        circleProgress.progressColor = UIColor.purpleRed()
    }
    
    //MARK: - ACTION
    
    @IBAction func onBackButton(_ sender: UIButton) {
        if let navController = navigationController {
            navController.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func startOrFinishButtonPressed(_ sender: UIButton) {
        if sender.titleLabel?.text == Constants.startButtonTitle {
//            activity.startActivity()
            scheduleFinishTimerForActivity()
            clearTimer()
            setupTimerCountdown()
        } else if sender.titleLabel?.text == Constants.finishButtonTitle {
//            activity.finishWithResult()
//            activity.deleteNonStandardNotifications()
            clearTimer()
            setup()
            drawProgressView()
        }
         // it's not enought only to delete it in next method to fully restart
        defineStartOrFinishButtonTitle()
    }
    
    func scheduleFinishTimerForActivity() {
//        if activity.isRoutine() {
//            activity.scheduleFinishTimerNotification()
//        } else {
//            activity.scheduleLastCallTimerNotification()
//        }
    }
    
    func defineStartOrFinishButtonTitle() {
//        if !activity.isDoneForToday() {
//            let buttonTitle = activity.isGoingNow() ? Constants.finishButtonTitle : Constants.startButtonTitle
//            flowControlButton.setTitle(buttonTitle, for: UIControlState())
//            flowControlButton.alpha = 1.0
//            flowControlButton.isUserInteractionEnabled = true
//        } else {
//            flowControlButton.alpha = 0.0
//            flowControlButton.isUserInteractionEnabled = false
//        }
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
//        let intervalTillAction = round(activity.timing.nextActionTime().timeIntervalSinceNow)
//        let intervalFromTimer = round(timer.getTimeRemaining())
//        if intervalTillAction != intervalFromTimer {
//            reloadTimer()
//        }
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
//        let lastResults = activity.lastWeekResults()
//        
//        if lastResults.count > 0 {
//            setValuesAndLabelsForGraph(lastResults)
//            chartView.strokeChart()
//        }
    }
    
    
    func setValuesAndLabelsForGraph(_ lastResults: [Result]) {
        for result in lastResults {
            lastWeekDayNames.append(result.shortDayNameForDate())
//            lastWeekResultValues.append(result.daySuccessForTiming(activity.timing))
        }
        
        addMissingResultsValuesAndLabels(lastResults)
        
        chartView.values = lastWeekResultValues
        chartView.lastWeekDaynames = lastWeekDayNames
    }
    
    func addMissingResultsValuesAndLabels(_ lastResults: [Result]) {
        if lastResults.count < 7 {
            let vacantDaysLeft = 7 - lastWeekResultValues.count
            for _ in 0 ..< (7 - lastResults.count) {
                lastWeekResultValues.insert(0.0, at: 0)
            }
            
//            let lastDay = Result.standardDateFormatter().date(from: lastResults.last!.date)
//            var components = (Calendar.current as NSCalendar).components([.year, .month, .day], from: lastDay!)
//            for _ in 0 ..< vacantDaysLeft {
//                components.day! -= 1
//                let nextDate = Calendar.current.date(from: components)
//                lastWeekDayNames.insert(Weekday.shortDayNameForDate(nextDate!), at: 0)
//            }
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditActivity" {
            if let vc = segue.destination as? EditActivityVC {
                vc.activity?.value = self.activity
            }
        }
    }
    

}
