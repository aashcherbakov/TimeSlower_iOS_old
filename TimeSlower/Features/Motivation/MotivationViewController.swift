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
        dismissMotivationController()
    }
    
    @IBAction func editButtonTapped(sender: AnyObject) {
        
    }
    
    @IBAction func okButtonTapped(sender: AnyObject) {
        dismissMotivationController()
    }
    
    func setupWithActivity(activity: Activity) {
        self.activity = activity
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let activity = activity else { return }
        
        activityNameLabel.text = activity.name
        activityBasisLabel.text = activity.activityBasisDescription()
        setupMotivationControlWithActivity(activity)
        setupStatsViewWithActivity(activity)
        view.setNeedsLayout()
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        motivationControl.setNeedsLayout()
        motivationControl.layoutIfNeeded()
    }
    
    // MARK: - Private Functions
    
    private func setupMotivationControlWithActivity(activity: Activity) {
        let lifeStats = LifetimeStats(withHours: activity.stats!.summHours)
        motivationControl.setupWithLifetimeStats(lifeStats)
    }
    
    private func setupStatsViewWithActivity(activity: Activity) {
        let startTime = dateFormatter.stringFromDate(activity.timing!.startTime)
        activityStatsView.setupWithStartTime(startTime, duration: activity.timing!.duration.shortDescription())
    }
    
    private func dismissMotivationController() {
        if let navigationController = navigationController {
            navigationController.popToRootViewControllerAnimated(true)
        } else {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
}
