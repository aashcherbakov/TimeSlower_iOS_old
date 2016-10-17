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
    @IBOutlet weak var timerImage: UIImageView!
    
    var activity: Activity?
    private var timer: MZTimerLabel?
    private var lastWeekDayNames = [String]()
    private var lastWeekResultValues = [Double]()
    private let scheduler = ActivityScheduler()
    private let notificationScheduler = NotificationScheduler()
    private var progressBarReady = false

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
        guard let activity = self.activity else { return }
        
        activityNameLabel.text = activity.name
        activityBasisLabel.text = activity.basis().description()
        timerStatusLabel.text = (activity.isGoingNow()) ? "finishes in" : "starts in"
        
        successLabel.text = String(format: "%.1f", activity.averageSuccess)
        setupCircleProgress()
        launchTimer()
        defineStartOrFinishButtonTitle()
    }
    
    func setupCircleProgress() {
        guard let activity = self.activity else { return }
        
        circleProgress.updateProgress(CGFloat(activity.averageSuccess))
        circleProgress.thicknessRatio = 0.02
        circleProgress.progressTintColor = UIColor.purpleRed()
    }
    
    //MARK: - ACTION
    
    @IBAction func onBackButton(_ sender: UIButton) {
        if let navController = navigationController {
            navController.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func editActivity(_ sender: AnyObject) {
        guard let activity = activity else {
            return
        }
        
        showEdit(activity: activity)
    }
    
    @IBAction func startOrFinishButtonPressed(_ sender: UIButton) {
        guard let activity = self.activity else { return }
        
        if sender.titleLabel?.text == Constants.startButtonTitle {
            let startedActivity = scheduler.start(activity: activity)
            notificationScheduler.scheduleForActivity(activity: startedActivity, notificationType: .Finish)
            self.activity = startedActivity
            clearTimer()
            setupTimerCountdown()
        } else if sender.titleLabel?.text == Constants.finishButtonTitle {
            self.activity = scheduler.finish(activity: activity)
            progressBarReady = false
            clearTimer()
            setup()
            drawProgressView()
        }
         // it's not enought only to delete it in next method to fully restart
        defineStartOrFinishButtonTitle()
    }
    
    func defineStartOrFinishButtonTitle() {
        guard let activity = self.activity else { return }

        if !activity.isDone() {
            let buttonTitle = activity.isGoingNow() ? Constants.finishButtonTitle : Constants.startButtonTitle
            flowControlButton.setTitle(buttonTitle, for: UIControlState())
            flowControlButton.alpha = 1.0
            flowControlButton.isUserInteractionEnabled = true
            timerStatusLabel.alpha = 1.0
            timerImage.alpha = 1.0
            timerLabel.alpha = 1.0
        } else {
            flowControlButton.alpha = 0.0
            flowControlButton.isUserInteractionEnabled = false
            timerStatusLabel.alpha = 0.0
            timerImage.alpha = 0.0
            timerLabel.alpha = 0.0
        }
    }

    // MARK: - TIMER
    
    func launchTimer() {
        if let timer = self.timer {
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
        
        guard let activity = self.activity else { return }

        if timer != nil {
            timer?.removeFromSuperview()
            timer = nil
        }
        
        timer = MZTimerLabel(label: timerLabel, andTimerType: MZTimerLabelTypeTimer)
        timer?.setupStandardTimerForActivity(activity)
    }
    
    func restartTimerIfActivityChanged() {
        guard let activity = self.activity, let timer = self.timer else { return }

        let intervalTillAction = round(activity.nextActionTime().timeIntervalSinceNow)
        let intervalFromTimer = round(timer.getTimeRemaining())
        if intervalTillAction != intervalFromTimer {
            reloadTimer()
        }
    }
    
    func reloadTimer() {
        if timer != nil {
            timer?.removeFromSuperview()
            timer = nil
            setupTimerCountdown()
        }
    }
    
    func clearTimer() {
        timer?.pause()
        timer?.removeFromSuperview()
        timer = nil
    }
    
    //MARK: - GRAPH
    
    private func drawProgressView() {
        guard let activity = self.activity else { return }

        if !progressBarReady {
            let lastResults = activity.lastWeekResults()
            
            if lastResults.count > 0 {
                setValuesAndLabelsForGraph(lastResults)
                chartView.strokeChart()
            }
            
            progressBarReady = true
        }
    }
    
    private func setValuesAndLabelsForGraph(_ lastResults: [Result]) {
        for result in lastResults {
            lastWeekDayNames.append(result.shortDayNameForDate())
            lastWeekResultValues.append(result.success)
        }
        
        addMissingResultsValuesAndLabels(lastResults)
        
        chartView.values = lastWeekResultValues
        chartView.lastWeekDaynames = lastWeekDayNames
    }
    
    private func addMissingResultsValuesAndLabels(_ lastResults: [Result]) {
        if lastResults.count < 7 {
            let vacantDaysLeft = 7 - lastWeekResultValues.count
            
            if vacantDaysLeft > 0 {
                for _ in 0 ..< (7 - lastResults.count) {
                    lastWeekResultValues.insert(0.0, at: 0)
                }
                
                let lastDay = StaticDateFormatter.shortDateNoTimeFromatter.date(from: lastResults.last!.stringDate)
                var components = (Calendar.current as NSCalendar).components([.year, .month, .day], from: lastDay!)
                for _ in 0 ..< vacantDaysLeft {
                    components.day! -= 1
                    let nextDate = Calendar.current.date(from: components)
                    lastWeekDayNames.insert(Weekday.shortDayNameForDate(nextDate!), at: 0)
                }
            }
        }
    }
    
    // MARK: - Navigation

    private func showEdit(activity: Activity) {
        let editController: EditActivityVC = ControllerFactory.createController()
        editController.activity.value = activity
        if let navigationController = navigationController {
            navigationController.pushViewController(editController, animated: true)
        } else {
            present(editController, animated: true, completion: nil)
        }
    }

}
