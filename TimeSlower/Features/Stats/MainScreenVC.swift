//
//  MainScreenVC.swift
//  TimeSlower2
//
//  Created by Aleksander Shcherbakov on 5/1/15.
//  Copyright (c) 2015 1lastDay. All rights reserved.
//

import UIKit
import CoreData
import TimeSlowerKit

class MainScreenVC: MainScreenVCConstraints {

    struct Constants {
        static let currentStatusCurrentActivity = "Current activity"
        static let currentStatusNextActivity = "Next activity"
        static let timingStatusStartsIn = "starts in"
        static let timingStatusFinishesIn = "finishes in"
        static let startNowButtonTitle = "Start now"
        static let finishNowButtonTitle = "Finish now"
    }
    
    //MARK: - Variables
    
    @IBOutlet weak var periodTitleLabel: UILabel!
    @IBOutlet weak var topWhiteView: UIView!
    @IBOutlet weak var controlFlowButton: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var activityNameLabel: UILabel!
    @IBOutlet weak var currentStatusLabel: UILabel!
    @IBOutlet weak var timingStatusLabel: UILabel!
    @IBOutlet weak var legendForGoalsLabel: UILabel!
    @IBOutlet weak var legendForRoutinesLabel: UILabel!
    @IBOutlet weak var menuButton: UIButton!
    
    fileprivate lazy var activityStoryboard: UIStoryboard = {
        return UIStoryboard(name: kActivityStoryboard, bundle: nil)
    }()
    
    fileprivate lazy var profileStoryboard: UIStoryboard = {
        return UIStoryboard(name: kProfileStoryboard, bundle: nil)
    }()
    
    var userProfile: Profile?
    var nextActivity: Activity!
    var pageViewController: UIPageViewController!
    var numberOfPages = 4
    var timer: MZTimerLabel!
    
    let transitionManager = MenuTransitionManager()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        transitionManager.sourceViewController = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if userProfile == nil {
            userProfile = CoreDataStack.sharedInstance.fetchProfile()
        }
        setup()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if pageViewController != nil {
            pageViewController.view.bounds = self.topWhiteView.bounds
            pageViewController.view.frame = CGRect(x: 0, y: 0, width: topWhiteView.frame.width, height: topWhiteView.frame.height)
        }
    }
    
    func setup() {
        if userProfile == nil {
            presentVCtoCreateNewProfile()
        } else {
            if userProfile?.allActivities().count == 0 {
                presentVCtoCreateFirstRoutine()
            } else {
                setupNextActivityBlock()
                setupPageViewController()
            }
        }
    }
    
    //MARK: - Setup
    
    func setupNextActivityBlock() {
        nextActivity = userProfile?.findCurrentActivity()
        setupControlFlowButton()
        if let activity = nextActivity {
            launchTimer()
            activityNameLabel.text = nextActivity.name.uppercased()
            currentStatusLabel.text = activity.isGoingNow() ? Constants.currentStatusCurrentActivity : Constants.currentStatusNextActivity
            timingStatusLabel.text = activity.isGoingNow() ? Constants.timingStatusFinishesIn : Constants.timingStatusStartsIn
        } else {
            activityNameLabel.text = "Create an activity first"
            timingStatusLabel.text = ""
            timerLabel.text = ""
        }
    }
    
    func setupControlFlowButton() {
        controlFlowButton.layer.cornerRadius = startNowButtonHeight.constant / 2
        if nextActivity != nil {
            let buttonTitle = nextActivity.isGoingNow() ? Constants.finishNowButtonTitle : Constants.startNowButtonTitle
            controlFlowButton.setTitle(buttonTitle, for: UIControlState())
            controlFlowButton.isEnabled = true
        } else {
            controlFlowButton.setTitle("No activities", for: .disabled)
            controlFlowButton.isEnabled = false
        }
    }

    func setupPageViewController() {
        if pageViewController == nil {
            pageViewController = activityStoryboard.instantiateViewController(withIdentifier: "Page View Controller") as! UIPageViewController
            pageViewController.dataSource = self
            
            let startVC = viewControllerAtIndex(0) as! CircleStatsVC
            let viewControllers = [startVC]
            
            pageViewController.setViewControllers(viewControllers, direction: .forward, animated: true, completion: nil)
            addChildViewController(pageViewController)
            topWhiteView.addSubview(pageViewController.view)
            pageViewController.didMove(toParentViewController: self)
        }
    }
    
    func viewControllerAtIndex(_ index: Int) -> UIViewController {
        let vc: CircleStatsVC = storyboard?.instantiateViewController(withIdentifier: "CircleStatsVC") as! CircleStatsVC
        vc.profile = self.userProfile
        vc.period = PastPeriod(rawValue: index)
        vc.pageIndex = index
        vc.delegate = self
        return vc
    }
    
    //MARK: - Timer setup
    
    func launchTimer() {
        if timer != nil {
            if !timer.counting {
                setupTimerCountdown()
            } else {
                restartTimerIfProfileHasChanged()
            }
        } else {
            setupTimerCountdown()
        }
    }
    
    func restartTimerIfProfileHasChanged() {
//        let timeTillFinalDate = nextActivity.timing.nextActionTime()
//        let timeTillEndOfCountdown = timer.getTimeRemaining()
//        
//        if timeTillFinalDate != timeTillEndOfCountdown {
//            reloadTimer()
//        }
    }
    
    func setupTimerCountdown() {
        timer = MZTimerLabel(label: timerLabel, andTimerType: MZTimerLabelTypeTimer)
        timer.setCountDownTo(nextActivity.timing.nextActionTime())
        timer.resetTimerAfterFinish = false
        
        let timerSecondsToSet = nextActivity.timing.nextActionTime().timeIntervalSinceNow
        timer.timeFormat = (timerSecondsToSet > 60*60) ? "mm:ss:SS" : "HH:mm:ss"
        if timerSecondsToSet > 60*60*24 {
            let hours = round((timerSecondsToSet - 60*60) / 60 / 60)
            timer.timeFormat = NSString(format: "%@:mm:ss", hours.format(".0")) as String
        }
        
        timer.start()
    }
    
    func reloadTimer() {
        if timer != nil {
            timer.removeFromSuperview()
            timer = nil
            setupTimerCountdown()
        }
    }

 
    //MARK: - Actions
    @IBAction func onControlFlowButton(_ sender: UIButton) {
        if sender.titleLabel!.text == Constants.startNowButtonTitle {
            startActivity()
        } else if sender.titleLabel!.text == Constants.finishNowButtonTitle {
            finishActivity()
        }
    }
    
    func startActivity() {
        nextActivity.timing.manuallyStarted = Date()
        //TODO: update notifications for today
        setupNextActivityBlock()
    }
    
    func finishActivity() {
        nextActivity.finishWithResult()
        nextActivity.deleteScheduledNotificationsForCurrentActivity()
        nextActivity.scheduleRestorationTimer()
        showActivityStatsViewController()
    }
    
    @IBAction func onAllActivitiesButton(_ sender: AnyObject) {
        let allActivitiesController: ListOfActivitiesVC = ControllerFactory.createController()
        allActivitiesController.profile = userProfile
        navigationController?.pushViewController(allActivitiesController, animated: true)
    }
    

    
    @IBAction func onMenuButton(_ sender: UIButton) {
        let menuVC: MenuVC = ControllerFactory.createController()
        menuVC.transitioningDelegate = transitionManager
        transitionManager.menuViewController = menuVC
        present(menuVC, animated: true, completion: nil)
    }
    
    fileprivate func showActivityStatsViewController() {
        if let activityStatsVC = activityStoryboard.instantiateViewController(withIdentifier: ActivityStatsVC.className) as? ActivityStatsVC {
            activityStatsVC.activity = nextActivity
            present(activityStatsVC, animated: true, completion: nil)
        }
    }
    
    func presentVCtoCreateFirstRoutine() {
        let createActivityVC: EditActivityVC = ControllerFactory.createController()
        createActivityVC.userProfile = userProfile
        present(createActivityVC, animated: false, completion: nil)
    }
    
    func presentVCtoCreateNewProfile() {
        let createProfileVC: ProfileEditingVC = ControllerFactory.createController()
        present(createProfileVC, animated: true, completion: nil)
    }
    
    func presentProfileVCFromMenu() {
        if let profileVC = profileStoryboard.instantiateViewController(withIdentifier: ProfileStatsVC.className) as? ProfileStatsVC {
            presentedViewController?.dismiss(animated: true, completion: {
                profileVC.profile = self.userProfile
                self.navigationController?.pushViewController(profileVC, animated: true)
            })
        }
    }
    
    func presentListOfActivitiesVCFromMenu() {
        if let allActivitiesVC = activityStoryboard.instantiateViewController(withIdentifier: ListOfActivitiesVC.className) as? ListOfActivitiesVC {
            presentedViewController?.dismiss(animated: true, completion: {
                allActivitiesVC.profile = self.userProfile
                self.navigationController?.pushViewController(allActivitiesVC, animated: true)
            })
        }
    }
}

//MARK: - PageViewController Delegate
extension MainScreenVC: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let vc = viewController as! CircleStatsVC
        var index = vc.pageIndex as Int
        if (index == 0 || index == NSNotFound) { return nil }

        index -= 1

        return self.viewControllerAtIndex(index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let vc = viewController as! CircleStatsVC
        var index = vc.pageIndex as Int
        if (index == NSNotFound) { return nil }
        index += 1
        
        if (index == numberOfPages) { return nil }

        return self.viewControllerAtIndex(index)
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return numberOfPages
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
}

extension MainScreenVC: CircleStatsDelegate {
    func pageControllerDidChangeToPage(_ index: Int) {
//        periodTitleLabel.text = TimeMachine.stringForPeriod(PastPeriod(rawValue: index)!)
    }
}
