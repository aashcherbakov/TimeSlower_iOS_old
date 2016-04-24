//
//  MenuVC.swift
//  TimeSlower2
//
//  Created by Oleksandr Shcherbakov on 7/28/15.
//  Copyright (c) 2015 1lastDay. All rights reserved.
//

import UIKit
import TimeSlowerKit

class MenuVC: UIViewController {
    
    private enum MenuOptions: Int {
        case Profile = 1
        case CreateActivity
        case AllActivities
        case RateApp
        case Feedback
    }
    
    private struct Constants {
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
    
    private var profile: Profile?
    
    // MARK: - Overridden
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDesign()
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        // since we update constraints based on phone size, 
        // avatar form should is set here, not in viewDidLoad
        setupDefaultConstraints()
        setupAvatarForm()
    }
    
    // MARK: - Actions
    
    @IBAction func menuOptionTapped(sender: UIButton) {
        guard let selectedOption = MenuOptions(rawValue: sender.tag) else {
            return
        }
        presentControllerFromMenu(selectedOption)
    }
    
    @IBAction func dismissMenu(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Private Methods 
    
    // MARK: - Navigation
    
    private func presentControllerFromMenu(option: MenuOptions) {
        guard let transition = transitioningDelegate as? MenuTransitionManager else {
            return
        }
        
        if let controller = controllerForOption(option) {
            dismissViewControllerAnimated(true) {
                transition.sourceViewController?.presentViewController(controller, animated: false, completion: nil)
            }
        }
    }
    
    private func controllerForOption(option: MenuOptions) -> UIViewController? {
        switch option {
        case .Profile:
            return profileStatsWithNavigation()
        case .CreateActivity:
            return createActivityController()
        case .AllActivities:
            return activityListWithNavigation()
        default:
            return nil
        }
    }
    
    private func profileStatsWithNavigation() -> UIViewController {
        let navigationController = UINavigationController()
        let profileController: ProfileStatsVC = ControllerFactory.createController()
        profileController.profile = profile
        navigationController.viewControllers = [profileController]
        return navigationController
    }
    
    private func activityListWithNavigation() -> UIViewController {
        let navigationController = UINavigationController()
        let listController: ListOfActivitiesVC = ControllerFactory.createController()
        listController.profile = profile
        navigationController.viewControllers = [listController]
        return navigationController
    }
    
    private func createActivityController() -> UIViewController {
        let controller: EditActivityVC = ControllerFactory.createController()
        controller.userProfile = profile
        return controller
    }
    
    // MARK: - Design

    private func setupDesign() {
        guard let profile = CoreDataStack.sharedInstance.fetchProfile() else {
            return
        }
        
        self.profile = profile
        avatarImageView.image = UIImage(data: profile.photo)
        nameLabel.text = profile.name.uppercaseString
        countryLabel.text = profile.country.capitalizedString
    }

    private func setupDefaultConstraints() {
        let height = UIScreen.mainScreen().bounds.height
        avatarBackgroundHeight.constant = height * Constants.avatarBackgroundScale
        cellHeight.constant = height * Constants.cellHeightScale
        firstCellOffset.constant = height * Constants.firstCellOffsetScale
    }
    
    private func setupAvatarForm() {
        avatarBackground.layer.cornerRadius = avatarBackgroundHeight.constant / 2
        avatarBackground.layer.borderWidth = 1
        avatarBackground.layer.borderColor = UIColor.darkRed().CGColor
        avatarImageView.layer.cornerRadius = (avatarBackgroundHeight.constant - 8) / 2
        avatarImageView.clipsToBounds = true
    }
}
