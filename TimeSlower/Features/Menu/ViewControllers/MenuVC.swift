//
//  MenuVC.swift
//  TimeSlower2
//
//  Created by Oleksandr Shcherbakov on 7/28/15.
//  Copyright (c) 2015 1lastDay. All rights reserved.
//

import UIKit
import TimeSlowerKit


@objc protocol MenuVCDelegate {
    func menuOptionSelected(option: Int)
}

class MenuVC: UIViewController {
    
    enum MenuOptions: Int {
        case Profile = 1
        case CreateActivity
        case AllActivities
        case RateApp
        case Feedback
    }
    
    struct Constants {
        static let profileSegueID = "ProfileStats"
        static let createActivitySegueID = "CreateNewActivity"
        static let allActivitiesSegueID = "AllActivities"
        static let avatarBackgroundScale: CGFloat = 0.21
        static let cellHeightScale: CGFloat = 0.08
        static let firstCellOffsetScale: CGFloat = 0.04
    }
    //MARK: - Constraints
    @IBOutlet weak var avatarBackgroundHeight: NSLayoutConstraint!
    @IBOutlet weak var cellHeight: NSLayoutConstraint!
    @IBOutlet weak var firstCellOffset: NSLayoutConstraint!
    
    
    //MARK: - Outlets
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var avatarBackground: UIView!
    
    var profile: Profile!
    var delegate: MenuVCDelegate?
    
    //MARK: - Layout
    override func updateViewConstraints() {
        super.updateViewConstraints()
        setupDefaultConstraints()
    }
    
    func setupDefaultConstraints() {
        let height = UIScreen.mainScreen().bounds.height
        avatarBackgroundHeight.constant = height * Constants.avatarBackgroundScale
        cellHeight.constant = height * Constants.cellHeightScale
        firstCellOffset.constant = height * Constants.firstCellOffsetScale
        
        setupAvatarForm()

    }
    
    //MARK: - Setup
    override func viewDidLoad() {
        super.viewDidLoad()

        profile = CoreDataStack.sharedInstance.fetchProfile()
        avatarImageView.image = UIImage(data: profile.photo)
        nameLabel.text = profile.name.uppercaseString
        countryLabel.text = profile.country.capitalizedString
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if profile == nil {
            profile = CoreDataStack.sharedInstance.fetchProfile()
        }
    }

    func setupAvatarForm() {
        avatarBackground.layer.cornerRadius = avatarBackgroundHeight.constant / 2
        avatarBackground.layer.borderWidth = 1
        avatarBackground.layer.borderColor = UIColor.darkRed().CGColor
        
        avatarImageView.layer.cornerRadius = (avatarBackgroundHeight.constant - 8) / 2
        avatarImageView.clipsToBounds = true
        
    }
    
    @IBAction func menuOptionTapped(sender: UIButton) {
        delegate?.menuOptionSelected(sender.tag)
        print("Selected menu option: \(sender.tag)")
    }
    
    
}
