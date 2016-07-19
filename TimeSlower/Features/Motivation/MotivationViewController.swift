//
//  MotivationViewController.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 7/11/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import UIKit
import TimeSlowerKit

class MotivationViewController: UIViewController {

    @IBOutlet weak var activityNameLabel: UILabel!
    @IBOutlet weak var activityBasisLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var motivationControl: MotivationControl!
    @IBOutlet weak var activityStatsView: MotivationStatsView!
    private(set) var activity: Activity?
    lazy var dateFormatter: NSDateFormatter = {
        return DateManager.sharedShortDateFormatter()
    }()
    
    @IBAction func backButtonTapped(sender: AnyObject) {
        if let navigationController = navigationController {
            navigationController.popViewControllerAnimated(true)
        } else {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    @IBAction func editButtonTapped(sender: AnyObject) {
        
    }
    
    @IBAction func okButtonTapped(sender: AnyObject) {
        if let navigationController = navigationController {
            navigationController.popToRootViewControllerAnimated(true)
        } else {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func setupWithActivity(activity: Activity) {
        self.activity = activity
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let activity = activity else { return }
        
        activityNameLabel.text = activity.name
        activityBasisLabel.text = activity.activityBasisDescription()
        
        // TODO: here will be a bug if we save hours
        let duration = activity.timing!.timeToSave.stringValue
        
        let basis = descriptionForActivityBasis(activity)
        summaryLabel.text = "cutting \(duration) minutes of \(activity.name!) \(basis) will save in your lifetime:".uppercaseString
        
        setupMotivationControlWithActivity(activity)
        setupStatsViewWithActivity(activity)
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        motivationControl.setNeedsLayout()
        motivationControl.layoutIfNeeded()
    }
    
    // MARK: - Private Functions
    
    private func descriptionForActivityBasis(activity: Activity) -> String {
        guard let basis = Basis(rawValue: activity.basis!.integerValue) else { return "" }
        switch basis {
        case .Random:
            return "\(activity.days.count) days a week"
        case .Daily: return "daily"
        case .Weekends: return "on weekends"
        case .Workdays: return "during workdays"
        }
    }
    
    private func setupMotivationControlWithActivity(activity: Activity) {
        let days = activity.profile!.numberOfDaysTillEndOfLifeSinceDate(NSDate())
        let hours = TimeCalculator().totalHours(inDays: days, duration: activity.timing!.timeToSave.integerValue, busyDays: activity.days.count)
        let lifeStats = LifetimeStats(withHours: hours)
        motivationControl.setupWithLifetimeStats(lifeStats)
    }
    
    private func setupStatsViewWithActivity(activity: Activity) {
        let startTime = dateFormatter.stringFromDate(activity.timing!.startTime)
        activityStatsView.setupWithStartTime(startTime, duration: activity.timing!.duration.shortDescription())
    }
}
