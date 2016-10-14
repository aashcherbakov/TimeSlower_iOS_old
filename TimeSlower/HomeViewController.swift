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
    
    let transitionManager = MenuTransitionManager()
    let activityListTransitionManager = ListTransitionManager()
    var progressCalculator: ProgressCalculator!
    let scheduler = ActivityScheduler()

    @IBOutlet fileprivate(set) weak var controlFlowButtonHeight: NSLayoutConstraint!
    @IBOutlet fileprivate(set) weak var controlFlowButton: UIButton!
    @IBOutlet fileprivate(set) weak var closestActivityDisplay: ClosestActivityDisplay!
    @IBOutlet fileprivate(set) weak var circleSatsView: CircleStatsView!
    
    var profile = MutableProperty<Profile?>(nil)
    var closestActivity = MutableProperty<Activity?>(nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let profile = profile.value {
            progressCalculator = ProgressCalculator(withProfile: profile)
        }
        
        setupDesign()
        setupEvents()
        transitionManager.sourceViewController = self
        activityListTransitionManager.sourceController = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }
    
    // MARK: - Actions
    
    @IBAction func controlFlowButtonTapped(_ sender: UIButton) {
        guard let activity = closestActivity.value else {
            if sender.titleLabel?.text == Constants.noActivitiesButtonTitle {
                createNewActivity()
            }
            return
        }
        
        if sender.titleLabel?.text == Constants.startNowButtonTitle {
            startActivity(activity)
        } else if sender.titleLabel?.text == Constants.finishNowButtonTitle {
            finishActivity(activity)
            closestActivity.value = scheduler.nextClosestActivity()
        }
    }
    
    @IBAction func openMenu(_ sender: UIBarButtonItem) {
        let menuVC: MenuVC = ControllerFactory.createController()
        menuVC.transitioningDelegate = transitionManager
        transitionManager.menuViewController = menuVC
        present(menuVC, animated: true, completion: nil)
    }
    
    // MARK: - Private Functions - ActivityDisplay
    
    fileprivate func startActivity(_ activity: Activity) {
        closestActivity.value = scheduler.start(activity: activity)
        
        //TODO: update notifications for today
        setupClosestActvityDisplay()
        setupControlFlowButton()
    }
    
    fileprivate func finishActivity(_ activity: Activity) {
        let finishedActivity = scheduler.finish(activity: activity)
        
        // TODO: update notifications
//        activity.deleteScheduledNotificationsForCurrentActivity()
//        activity.scheduleRestorationTimer()
        showStatsControllerForActivity(finishedActivity)
    }
    
    fileprivate func setupClosestActvityDisplay() {
        let activity = closestActivityForToday()
        closestActivityDisplay.setupWithActivity(activity)
        displayProgress()
    }
    
    private func closestActivityForToday() -> Activity? {
        if let activity = scheduler.currentActivity() {
            return activity
        } else {
            return scheduler.nextClosestActivity()
        }
    }

    // MARK: - Private Functions - Design
    
    fileprivate func setupEvents() {
        profile.producer.startWithValues { [weak self] (profile) in
            if let profile = profile {
                self?.setupClosestActvityDisplay()
                self?.setupControlFlowButton()
            }
        }
    }
    
    private func displayProgress() {
        circleSatsView.displayProgress(progress: progressCalculator.progressForDate())
    }
    
    fileprivate func setupDesign() {
        setupClosestActvityDisplay()
        setupControlFlowButton()
        
        navigationItem.title = StaticDateFormatter.fullDateFormatter.string(from: Date())
    }
    
    private func setupControlFlowButton() {
        controlFlowButton.layer.cornerRadius = Constants.controlFlowButtonHeight / 2
        controlFlowButtonHeight.constant = Constants.controlFlowButtonHeight

        if let closestActivity = closestActivity.value {
            let buttonTitle = closestActivity.isGoingNow() ? Constants.finishNowButtonTitle : Constants.startNowButtonTitle
            controlFlowButton.setTitle(buttonTitle, for: .normal)
        } else {
            controlFlowButton.setTitle(Constants.noActivitiesButtonTitle, for: .normal)
        }
    }
    
    fileprivate func setupNavigationBar() {
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
    }
    
    // MARK: - Private Function - Navigation
    
    private func showStatsControllerForActivity(_ activity: Activity) {
        let controller: ActivityStatsVC = ControllerFactory.createController()
        controller.activity = activity
        present(controller, animated: true, completion: nil)
    }
    
    private func createNewActivity() {
        let controller: EditActivityVC = ControllerFactory.createController()
        controller.userProfile = profile.value
        navigationController?.pushViewController(controller, animated: true)
    }
}
