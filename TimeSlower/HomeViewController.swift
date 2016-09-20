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
    }
    
    let transitionManager = MenuTransitionManager()
    let activityListTransitionManager = ListTransitionManager()

    @IBOutlet fileprivate(set) weak var controlFlowButtonHeight: NSLayoutConstraint!
    @IBOutlet fileprivate(set) weak var controlFlowButton: UIButton!
    @IBOutlet fileprivate(set) weak var closestActivityDisplay: ClosestActivityDisplay!
    @IBOutlet fileprivate(set) weak var circleSatsView: CircleStatsView!
    
    var profile: MutableProperty<Profile>?
    var closestActivity: MutableProperty<Activity>?

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        guard let activity = closestActivity else { return }
        
        if sender.titleLabel?.text == Constants.startNowButtonTitle {
            startActivity(activity.value)
        } else if sender.titleLabel?.text == Constants.finishNowButtonTitle {
            finishActivity(activity.value)
//            closestActivity = profile?.value.findCurrentActivity()
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
//        activity.timing.manuallyStarted = Date()
        //TODO: update notifications for today
        setupClosestActvityDisplay()
        setupControlFlowButton()
    }
    
    fileprivate func finishActivity(_ activity: Activity) {
//        activity.finishWithResult()
//        activity.deleteScheduledNotificationsForCurrentActivity()
//        activity.scheduleRestorationTimer()
//        showStatsControllerForActivity(activity)
    }
    
    fileprivate func setupClosestActvityDisplay() {
//        closestActivity = profile?.findCurrentActivity()        
//        closestActivityDisplay.setupWithActivity(closestActivity)
//        circleSatsView.displayProgressForProfile(closestActivity?.profile)
    }

    // MARK: - Private Functions - Design
    
    fileprivate func setupEvents() {
//        rac_valuesForKeyPath("profile", observer: self).toSignalProducer()
//            .startWithNext { [weak self] (_) in
//                self?.setupClosestActvityDisplay()
//                self?.setupControlFlowButton()
//        }
    }
    
    fileprivate func setupDesign() {
        setupClosestActvityDisplay()
        setupControlFlowButton()
    }
    
    fileprivate func setupControlFlowButton() {
        controlFlowButton.layer.cornerRadius = Constants.controlFlowButtonHeight / 2
        controlFlowButtonHeight.constant = Constants.controlFlowButtonHeight

        if let closestActivity = closestActivity {
//            let buttonTitle = closestActivity.isGoingNow() ? Constants.finishNowButtonTitle : Constants.startNowButtonTitle
//            controlFlowButton.setTitle(buttonTitle, for: UIControlState())
            controlFlowButton.isEnabled = true
        } else {
            controlFlowButton.setTitle("No activities", for: .disabled)
            controlFlowButton.isEnabled = false
        }
    }
    
    fileprivate func setupNavigationBar() {
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
    }
    
    // MARK: - Private Function - Navigation
    
    fileprivate func showStatsControllerForActivity(_ activity: Activity) {
        let controller: ActivityStatsVC = ControllerFactory.createController()
        controller.activity = activity
        present(controller, animated: true, completion: nil)
    }
}
