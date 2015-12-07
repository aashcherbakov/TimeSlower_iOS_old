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

@objc protocol MainScreenVCDelegate {
    optional func toggleMenuWithDelay(delay: Double)
    optional func collapseMenu()
}

class MainScreenVC: MainScreenVCConstraints {

    struct Constants {
        //Segue ID's
        static let activityStatsSegue = "Activity Stats"
        static let allActivitiedSegue = "All Activities"
        
        // Storyboard IDs
        static let profileStatsStoryboardID = "ProfileStatsVC"
        static let createProfileStoryboardID = "ProfileEditingVC"
        static let createRoutineStoryboardID = "EditActivityVC"
        static let createAllActivitiesStoryboardID = "ListOfActivitiesVC"
        
        // Label names
        static let currentStatusCurrentActivity = "Current activity"
        static let currentStatusNextActivity = "Next activity"
        static let timingStatusStartsIn = "starts in"
        static let timingStatusFinishesIn = "finishes in"
        static let startNowButtonTitle = "Start now"
        static let finishNowButtonTitle = "Finish now"
    }
    
    //MARK: - Outlets
    
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
    
    //MARK: - Properties
    var delegate: MainScreenVCDelegate?
    var userProfile: Profile?
    var nextActivity: Activity!
    var pageViewController: UIPageViewController!
    var numberOfPages = 4
    var timer: MZTimerLabel!
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBarHidden = true
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if userProfile == nil { userProfile = CoreDataStack.sharedInstance.fetchProfile() }
        setup()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if pageViewController != nil {
            pageViewController.view.bounds = self.topWhiteView.bounds
            pageViewController.view.frame = CGRectMake(0, 0, topWhiteView.frame.width, topWhiteView.frame.height)
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
            pageViewController = storyboard?.instantiateViewControllerWithIdentifier("Page View Controller") as! UIPageViewController
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
    
    func finishActivity() {
        nextActivity.finishWithResult()
        nextActivity.deleteScheduledNotificationsForCurrentActivity()
        nextActivity.scheduleRestorationTimer()
        performSegueWithIdentifier(Constants.activityStatsSegue, sender: self)
    }
    
    @IBAction func onMenuButton(sender: UIButton) {
        delegate?.toggleMenuWithDelay?(0.0)
    }
    
    
    // MARK: - Navigation
    
    @IBAction func profileCreated(segue: UIStoryboardSegue) {
        userProfile = CoreDataStack.sharedInstance.fetchProfile()
        if userProfile == nil {
            print("Profile is not created, try another option")
        }
    }
    
    @IBAction func activityCreated(segue: UIStoryboardSegue) { }
    
    func presentVCtoCreateFirstRoutine() {
        let createActivityVC = UIStoryboard.mainStoryboard().instantiateViewControllerWithIdentifier(Constants.createRoutineStoryboardID) as! EditActivityVC
        createActivityVC.userProfile = self.userProfile
        presentViewController(createActivityVC, animated: false, completion: nil)
    }
    
    func presentVCtoCreateNewProfile() {
        let createProfileVC = UIStoryboard(name: "Profile", bundle: nil).instantiateViewControllerWithIdentifier(Constants.createProfileStoryboardID) as! ProfileEditingVC
        presentViewController(createProfileVC, animated: false, completion: nil)
    }
    
    func presentProfileVCFromMenu() {
        let profileVC = UIStoryboard.mainStoryboard().instantiateViewControllerWithIdentifier(Constants.profileStatsStoryboardID) as! ProfileStatsVC
        profileVC.profile = self.userProfile
        navigationController?.pushViewController(profileVC, animated: false)
    }
    
    func presentListOfActivitiesVCFromMenu() {
        let allActivitiesVC = UIStoryboard.mainStoryboard().instantiateViewControllerWithIdentifier(Constants.createAllActivitiesStoryboardID) as! ListOfActivitiesVC
        allActivitiesVC.profile = self.userProfile
        navigationController?.pushViewController(allActivitiesVC, animated: false)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Constants.allActivitiedSegue {
            if let vc = segue.destinationViewController as? ListOfActivitiesVC {
                vc.profile = self.userProfile
            }
        }
        
        if segue.identifier == Constants.activityStatsSegue {
            if let activityStatsVC = segue.destinationViewController as? ActivityStatsVC {
                activityStatsVC.activity = nextActivity
            }
        }
    }
}

//MARK: - PageViewController Delegate
extension MainScreenVC: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let vc = viewController as! CircleStatsVC
        var index = vc.pageIndex as Int
        if (index == 0 || index == NSNotFound) { return nil }

        index--

        return self.viewControllerAtIndex(index)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let vc = viewController as! CircleStatsVC
        var index = vc.pageIndex as Int
        if (index == NSNotFound) { return nil }
        index++
        
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

extension MainScreenVC: MenuVCDelegate {
    func menuOptionSelected(option: Int) {
        let selectedOption = MenuVC.MenuOptions(rawValue: option)!
        
        delegate?.collapseMenu?()

        switch selectedOption {
        case .Profile: presentProfileVCFromMenu()
        case .CreateActivity: presentVCtoCreateFirstRoutine()
        case .AllActivities: presentListOfActivitiesVCFromMenu()
        default: break
        }

        //TODO: add segues for Feedback and Rate
        
    }
}



