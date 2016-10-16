//
//  HomeViewController.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 7/30/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import UIKit
import TimeSlowerKit
import ReactiveSwift

internal class HomeViewController: UIViewController {
    
    fileprivate struct Constants {
        static let controlFlowButtonHeight: CGFloat = 48
        static let startNowButtonTitle = "Start now"
        static let finishNowButtonTitle = "Finish now"
        static let noActivitiesButtonTitle = "Create Activity"
    }
    
    private enum ActionButtonState: String {
        case Start = "Start now"
        case Finish = "Finish now"
        case Create = "Create Activity"
    }
    
    let transitionManager = MenuTransitionManager()
    let activityListTransitionManager = ListTransitionManager()
    let progressCalculator = ProgressCalculator()
    let scheduler = ActivityScheduler()
    let notificationScheduler = NotificationScheduler()

    @IBOutlet fileprivate(set) weak var controlFlowButtonHeight: NSLayoutConstraint!
    @IBOutlet fileprivate(set) weak var controlFlowButton: UIButton!
    @IBOutlet fileprivate(set) weak var closestActivityDisplay: ClosestActivityDisplay!
    @IBOutlet fileprivate(set) weak var circleSatsView: CircleStatsView!
    
    var profile = MutableProperty<Profile?>(nil)
    var closestActivity = MutableProperty<Activity?>(nil)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
        
        // TODO: implement delegate to avoid reloading data on each appearance
        setupData()
        setupDesign()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupEvents()
    }
    
    private func setupData() {
        setupClosestActvityDisplay()
        displayProgress()
    }
    
    private func setupDesign() {
        setupControlFlowButton()
    }
    
    private func setupEvents() {
        transitionManager.sourceViewController = self
        activityListTransitionManager.sourceController = self
        
        closestActivity.producer.startWithValues { [weak self] (activity) in
            self?.updateButtonTitle(forActivity: activity)
        }
    }
    
    private func updateButtonTitle(forActivity activity: Activity?) {
        if let activity = activity {
            let buttonTitle = activity.isGoingNow() ? Constants.finishNowButtonTitle : Constants.startNowButtonTitle
            controlFlowButton.setTitle(buttonTitle, for: .normal)
        } else {
            controlFlowButton.setTitle(Constants.noActivitiesButtonTitle, for: .normal)
        }
    }
    
    private func setupClosestActvityDisplay() {
        let activity = closestActivityForToday()
        closestActivity.value = activity
        closestActivityDisplay.setupWithActivity(activity)
    }
    
    private func displayProgress() {
        circleSatsView.displayProgress(progress: progressCalculator.progressForDate())
    }
    
    private func setupControlFlowButton() {
        controlFlowButton.layer.cornerRadius = Constants.controlFlowButtonHeight / 2
        controlFlowButtonHeight.constant = Constants.controlFlowButtonHeight
    }
    
    // MARK: - Actions
    
    @IBAction func controlFlowButtonTapped(_ sender: UIButton) {
        guard let text = sender.titleLabel?.text, let buttonState = ActionButtonState(rawValue: text) else {
            return
        }
        switch buttonState {
        case .Create: showCreateNewActivity()
        case .Start: startActivity(closestActivity.value)
        case .Finish: finishActivity(closestActivity.value)
        }
    }
    
    @IBAction func openMenu(_ sender: UIBarButtonItem) {
        showMenue()
    }
    
    private func closestActivityForToday() -> Activity? {
        if let activity = scheduler.currentActivity() {
            return activity
        } else {
            return scheduler.nextClosestActivity()
        }
    }
    
    // MARK: - Private Functions - ActivityDisplay
    
    private func startActivity(_ activity: Activity?) {
        guard let activity = activity else { return }
        
        closestActivity.value = scheduler.start(activity: activity)
        
        notificationScheduler.scheduleForActivity(activity: activity, notificationType: .Finish)
        setupClosestActvityDisplay()
        setupControlFlowButton()
    }
    
    private func finishActivity(_ activity: Activity?) {
        guard let activity = activity else { return }
        let finishedActivity = scheduler.finish(activity: activity)
        
//        activity.deleteScheduledNotificationsForCurrentActivity()
//        activity.scheduleRestorationTimer()
        showStatsControllerForActivity(finishedActivity)
    }

    // MARK: - Private Functions - Design

    fileprivate func setupNavigationBar() {
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationItem.title = StaticDateFormatter.fullDateFormatter.string(from: Date())
    }
    
    // MARK: - Private Function - Navigation
    
    private func showMenue() {
        let menuVC: MenuVC = ControllerFactory.createController()
        menuVC.transitioningDelegate = transitionManager
        transitionManager.menuViewController = menuVC
        present(menuVC, animated: true, completion: nil)
    }
    
    private func showStatsControllerForActivity(_ activity: Activity) {
        let controller: ActivityStatsVC = ControllerFactory.createController()
        controller.activity = activity
        present(controller, animated: true, completion: nil)
    }
    
    private func showCreateNewActivity() {
        let controller: EditActivityVC = ControllerFactory.createController()
        controller.userProfile = profile.value
        navigationController?.pushViewController(controller, animated: true)
    }
}
