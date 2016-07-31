//
//  HomeViewController.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 7/30/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import UIKit
import TimeSlowerKit
import ReactiveCocoa

class HomeViewController: UIViewController {
    
    private struct Constants {
        static let controlFlowButtonHeight: CGFloat = 48
        static let startNowButtonTitle = "Start now"
        static let finishNowButtonTitle = "Finish now"
    }
    
    let transitionManager = MenuTransitionManager()

    @IBOutlet private(set) weak var controlFlowButtonHeight: NSLayoutConstraint!
    @IBOutlet private(set) weak var controlFlowButton: UIButton!
    @IBOutlet private(set) weak var closestActivityDisplay: ClosestActivityDisplay!
    
    dynamic var profile: Profile?
    var closestActivity: Activity?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDesign()
        setupEvents()
        transitionManager.sourceViewController = self
    }
    
    // MARK: - Actions
    
    @IBAction func controlFlowButtonTapped(sender: UIButton) {
        guard let activity = closestActivity else {
            return
        }
        
        if sender.titleLabel?.text == Constants.startNowButtonTitle {
            startActivity(activity)
        } else if sender.titleLabel?.text == Constants.finishNowButtonTitle {
            finishActivity(activity)
        }
    }
    
    private func startActivity(activity: Activity) {
        activity.timing!.manuallyStarted = NSDate()
        //TODO: update notifications for today
        setupDesign()
    }
    
    private func finishActivity(activity: Activity) {
        activity.finishWithResult()
        activity.deleteScheduledNotificationsForCurrentActivity()
        activity.scheduleRestorationTimer()
        showStatsControllerForActivity(activity)
    }
    
    @IBAction func openMenu(sender: UIBarButtonItem) {
        let menuVC: MenuVC = ControllerFactory.createController()
        menuVC.transitioningDelegate = transitionManager
        transitionManager.menuViewController = menuVC
        presentViewController(menuVC, animated: true, completion: nil)
    }
    
    // MARK: - Private Functions
    
    private func setupEvents() {
        rac_valuesForKeyPath("profile", observer: self).toSignalProducer()
            .startWithNext { [weak self] (_) in
                self?.setupClosestActvityDisplay()
                self?.setupControlFlowButton()
        }
    }
    
    private func setupDesign() {
        setupNavigationBar()
        setupClosestActvityDisplay()
        setupControlFlowButton()
    }
    
    private func setupClosestActvityDisplay() {
        closestActivity = profile?.findCurrentActivity()
        closestActivityDisplay.setupWithActivity(closestActivity)
    }
    
    private func setupControlFlowButton() {
        controlFlowButton.layer.cornerRadius = Constants.controlFlowButtonHeight / 2
        controlFlowButtonHeight.constant = Constants.controlFlowButtonHeight

        if let closestActivity = closestActivity {
            let buttonTitle = closestActivity.isGoingNow() ? Constants.finishNowButtonTitle : Constants.startNowButtonTitle
            controlFlowButton.setTitle(buttonTitle, forState: .Normal)
            controlFlowButton.enabled = true
        } else {
            controlFlowButton.setTitle("No activities", forState: .Disabled)
            controlFlowButton.enabled = false
        }
    }
    
    private func setupNavigationBar() {
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.translucent = true
    }
    
    // MARK: - Private Function - Navigation
    
    private func showStatsControllerForActivity(activity: Activity) {
        let controller: ActivityStatsVC = ControllerFactory.createController()
        controller.activity = activity
        presentViewController(controller, animated: true, completion: nil)
    }
}
