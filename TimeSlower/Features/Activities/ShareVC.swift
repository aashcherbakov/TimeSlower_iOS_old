//
//  ShareVC.swift
//  TimeSlower2
//
//  Created by Oleksandr Shcherbakov on 7/27/15.
//  Copyright (c) 2015 1lastDay. All rights reserved.
//

import UIKit
import TimeSlowerKit

class ShareVC: UIViewController {
    
    
    @IBOutlet weak var hoursLabel: UILabel!
    @IBOutlet weak var daysLabel: UILabel!
    @IBOutlet weak var monthsLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var shareButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var shareButtonHeight: NSLayoutConstraint!
    
    var lifeTime: Profile.LifeTime!
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        setupButton()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLabels()
    }

    func setupLabels() {
        monthsLabel.text = "\(lifeTime.months) MONTHS"
        daysLabel.text = "\(lifeTime.days) DAYS"
        hoursLabel.text = "\(lifeTime.hours) HOURS"
    }
    
    func setupButton() {
        shareButtonWidth.constant = kUsableViewWidth * LayoutConstants.buttonWidthScale
        shareButton.layer.cornerRadius = shareButton.frame.height / 2
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
