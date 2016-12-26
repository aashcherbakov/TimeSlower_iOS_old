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
import MessageUI

internal class HomeViewController: UIViewController {
    
    fileprivate let router = Router()
    
    fileprivate struct Constants {
        static let controlFlowButtonHeight: CGFloat = 48
        static let startNowButtonTitle = "Start now"
        static let finishNowButtonTitle = "Finish now"
        static let noActivitiesButtonTitle = "Create Activity"
    }
    
    private enum ActionButtonState: String {
        case start = "Start now"
        case finish = "Finish now"
        case create = "Create Activity"
    }
    
    var showStats: (Activity) -> () = { _ in }
    
    let transitionManager = MenuTransitionManager()
    let activityListTransitionManager = ListTransitionManager()
    let progressCalculator = ProgressCalculator()
    let scheduler = ActivityScheduler()
    let notificationScheduler = NotificationScheduler()

    @IBOutlet fileprivate(set) weak var controlFlowButtonHeight: NSLayoutConstraint!
    @IBOutlet fileprivate(set) weak var controlFlowButton: UIButton!
    @IBOutlet fileprivate(set) weak var closestActivityDisplay: ClosestActivityDisplay!
    @IBOutlet fileprivate(set) weak var circleSatsView: CircleStatsView!
    @IBOutlet weak var closestActivityDisplayHeight: NSLayoutConstraint!
    
    var profile = MutableProperty<Profile?>(nil)
    var closestActivity = MutableProperty<Activity?>(nil)
    
    // MARK: - Overridden 
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
        updateProfile()
        observeReturningToForeground()
        resetData()
        // TODO: implement delegate to avoid reloading data on each appearance
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupEvents()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Actions
    
    @IBAction func controlFlowButtonTapped(_ sender: UIButton) {
        guard let text = sender.titleLabel?.text, let buttonState = ActionButtonState(rawValue: text) else {
            return
        }
        switch buttonState {
        case .create: showCreateNewActivity()
        case .start: startActivity(closestActivity.value)
        case .finish: finishActivity(closestActivity.value)
        }
    }
    
    @IBAction func openMenu(_ sender: UIBarButtonItem) {
        showMenue()
    }
    
    func resetData() {
        setupData()
        setupDesign()
    }
    
    // MARK: - Private - Setup
    
    private func closestActivityForToday() -> Activity? {
        if let activity = scheduler.currentActivity() {
            return activity
        } else {
            return scheduler.nextClosestActivity()
        }
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
    
    private func observeReturningToForeground() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(resetData), name: .UIApplicationWillEnterForeground, object: nil)
    }
    
    private func updateProfile() {
        let updatedProfile: Profile? = DataStore().retrieve("")
        profile.value = updatedProfile
    }
    
    // MARK: - Private Functions - ActivityDisplay
    
    private func startActivity(_ activity: Activity?) {
        guard let activity = activity else { return }
        
        let startedActivity = scheduler.start(activity: activity)
        notificationScheduler.scheduleForActivity(activity: startedActivity, notificationType: .finish)
        closestActivity.value = startedActivity
        setupClosestActvityDisplay()
        setupControlFlowButton()
        
    }
    
    private func finishActivity(_ activity: Activity?) {
        guard let activity = activity else { return }
        let finishedActivity = scheduler.finish(activity: activity)
        notificationScheduler.cancelNotification(forActivity: finishedActivity, notificationType: .finish)
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
        let menuVC: MenuViewController = ControllerFactory.createController()
        menuVC.transitioningDelegate = transitionManager
        menuVC.profile = profile.value
        transitionManager.menuViewController = menuVC
        present(menuVC, animated: true, completion: nil)
    }
    
    private func showStatsControllerForActivity(_ activity: Activity) {
        let controller: ActivityStatsVC = ControllerFactory.createController()
        controller.activity = activity
        present(controller, animated: true, completion: nil)
    }
    
    private func showCreateNewActivity() {
        router.route(to: .editActivity(profile: profile.value!, activity: nil),
                     style: .push(navigationController: navigationController))
    }
}

extension HomeViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}

extension HomeViewController: Instantiatable {
    
    typealias SetupObject = Profile
    
    func setup(with object: Profile) {
        profile.value = object
    }
    
}
