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
    
    private lazy var activityStoryboard: UIStoryboard = {
        return UIStoryboard(name: kActivityStoryboard, bundle: nil)
    }()
    
    private lazy var profileStoryboard: UIStoryboard = {
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
        navigationController?.navigationBarHidden = true
        transitionManager.sourceViewController = self
    }
    
    override func viewWillAppear(animated: Bool) {
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
            pageViewController.view.frame = CGRectMake(0, 0, topWhiteView.frame.width, topWhiteView.frame.height)
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
            activityNameLabel.text = nextActivity.name.uppercaseString
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
            controlFlowButton.setTitle(buttonTitle, forState: .Normal)
            controlFlowButton.enabled = true
        } else {
            controlFlowButton.setTitle("No activities", forState: .Disabled)
            controlFlowButton.enabled = false
        }
    }

    func setupPageViewController() {
        if pageViewController == nil {
            pageViewController = activityStoryboard.instantiateViewControllerWithIdentifier("Page View Controller") as! UIPageViewController
            pageViewController.dataSource = self
            
            let startVC = viewControllerAtIndex(0) as! CircleStatsVC
            let viewControllers = [startVC]
            
            pageViewController.setViewControllers(viewControllers, direction: .Forward, animated: true, completion: nil)
            addChildViewController(pageViewController)
            topWhiteView.addSubview(pageViewController.view)
            pageViewController.didMoveToParentViewController(self)
        }
    }
    
    func viewControllerAtIndex(index: Int) -> UIViewController {
        let vc: CircleStatsVC = storyboard?.instantiateViewControllerWithIdentifier("CircleStatsVC") as! CircleStatsVC
        vc.profile = self.userProfile
        vc.period = LazyCalendar.Period(rawValue: index)
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
        let timeTillFinalDate = nextActivity.timing.nextActionTime()
        let timeTillEndOfCountdown = timer.getTimeRemaining()
        
        if timeTillFinalDate != timeTillEndOfCountdown {
            reloadTimer()
        }
    }
    
    func setupTimerCountdown() {
        timer = MZTimerLabel(label: timerLabel, andTimerType: MZTimerLabelTypeTimer)
        timer.setCountDownToDate(nextActivity.timing.nextActionTime())
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
    @IBAction func onControlFlowButton(sender: UIButton) {
        if sender.titleLabel!.text == Constants.startNowButtonTitle {
            startActivity()
        } else if sender.titleLabel!.text == Constants.finishNowButtonTitle {
            finishActivity()
        }
    }
    
    func startActivity() {
        nextActivity.timing.manuallyStarted = NSDate()
        //TODO: update notifications for today
        setupNextActivityBlock()
    }
    
    @IBAction func onAllActivitiesButton(sender: AnyObject) {
        let allActivitiesController: ListOfActivitiesVC = ControllerFactory.createController()
        allActivitiesController.profile = userProfile
        navigationController?.pushViewController(allActivitiesController, animated: true)
    }
    
    func finishActivity() {
        nextActivity.finishWithResult()
        nextActivity.deleteScheduledNotificationsForCurrentActivity()
        nextActivity.scheduleRestorationTimer()
        showActivityStatsViewController()
    }
    
    @IBAction func onMenuButton(sender: UIButton) {
        let menuVC: MenuVC = ControllerFactory.createController()
        menuVC.transitioningDelegate = transitionManager
        transitionManager.menuViewController = menuVC
        presentViewController(menuVC, animated: true, completion: nil)
    }
    
    private func showActivityStatsViewController() {
        if let activityStatsVC = activityStoryboard.instantiateViewControllerWithIdentifier(ActivityStatsVC.className) as? ActivityStatsVC {
            activityStatsVC.activity = nextActivity
            presentViewController(activityStatsVC, animated: true, completion: nil)
        }
    }
    
    func presentVCtoCreateFirstRoutine() {
        let createActivityVC: EditActivityVC = ControllerFactory.createController()
        createActivityVC.userProfile = userProfile
        presentViewController(createActivityVC, animated: false, completion: nil)
    }
    
    func presentVCtoCreateNewProfile() {
        let createProfileVC: ProfileEditingVC = ControllerFactory.createController()
        presentViewController(createProfileVC, animated: true, completion: nil)
    }
    
    func presentProfileVCFromMenu() {
        if let profileVC = profileStoryboard.instantiateViewControllerWithIdentifier(ProfileStatsVC.className) as? ProfileStatsVC {
            presentedViewController?.dismissViewControllerAnimated(true, completion: {
                profileVC.profile = self.userProfile
                self.navigationController?.pushViewController(profileVC, animated: true)
            })
        }
    }
    
    func presentListOfActivitiesVCFromMenu() {
        if let allActivitiesVC = activityStoryboard.instantiateViewControllerWithIdentifier(ListOfActivitiesVC.className) as? ListOfActivitiesVC {
            presentedViewController?.dismissViewControllerAnimated(true, completion: {
                allActivitiesVC.profile = self.userProfile
                self.navigationController?.pushViewController(allActivitiesVC, animated: true)
            })
        }
    }
}

//MARK: - PageViewController Delegate
extension MainScreenVC: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let vc = viewController as! CircleStatsVC
        var index = vc.pageIndex as Int
        if (index == 0 || index == NSNotFound) { return nil }

        index -= 1

        return self.viewControllerAtIndex(index)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let vc = viewController as! CircleStatsVC
        var index = vc.pageIndex as Int
        if (index == NSNotFound) { return nil }
        index += 1
        
        if (index == numberOfPages) { return nil }

        return self.viewControllerAtIndex(index)
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return numberOfPages
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
}

extension MainScreenVC: CircleStatsDelegate {
    func pageControllerDidChangeToPage(index: Int) {
        periodTitleLabel.text = LazyCalendar.stringForPeriod(LazyCalendar.Period(rawValue: index)!)
    }
}
