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
    
    fileprivate enum MenuOptions: Int {
        case profile = 1
        case createActivity
        case allActivities
        case rateApp
        case feedback
    }
    
    fileprivate struct Constants {
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
    
    var profile: Profile?
    
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
    
    @IBAction func menuOptionTapped(_ sender: UIButton) {
        guard let selectedOption = MenuOptions(rawValue: sender.tag) else {
            return
        }
        presentControllerFromMenu(selectedOption)
    }
    
    @IBAction func dismissMenu(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Private Methods 
    
    // MARK: - Navigation
    
    fileprivate func presentControllerFromMenu(_ option: MenuOptions) {
        guard let transition = transitioningDelegate as? MenuTransitionManager else {
            return
        }
        
        if let controller = controllerForOption(option) {
            transition.sourceViewController?.navigationController?.pushViewController(controller, animated: false)
            dismiss(animated: true, completion: nil)
        }
    }
    
    fileprivate func controllerForOption(_ option: MenuOptions) -> UIViewController? {
        switch option {
        case .profile:
            return profileStatsController()
        case .createActivity:
            return createActivityController()
        case .allActivities:
            return activityListController()
        default:
            return nil
        }
    }
    
    fileprivate func profileStatsController() -> UIViewController {
        let profileController: ProfileStatsVC = ControllerFactory.createController()
        profileController.profile = profile
        return profileController
    }
    
    fileprivate func activityListController() -> UIViewController {
        let listController: ListOfActivitiesVC = ControllerFactory.createController()
        return listController
    }
    
    fileprivate func createActivityController() -> UIViewController {
        let controller: EditActivityVC = ControllerFactory.createController()
        controller.userProfile = profile
        return controller
    }
    
    // MARK: - Design

    fileprivate func setupDesign() {
        guard let profile = profile else {
            return
        }
        
        nameLabel.text = profile.name.uppercased()
        countryLabel.text = profile.country.capitalized
        avatarImageView.image = profile.photo
    }

    fileprivate func setupDefaultConstraints() {
        let height = UIScreen.main.bounds.height
        avatarBackgroundHeight.constant = height * Constants.avatarBackgroundScale
        cellHeight.constant = height * Constants.cellHeightScale
        firstCellOffset.constant = height * Constants.firstCellOffsetScale
    }
    
    fileprivate func setupAvatarForm() {
        avatarBackground.layer.cornerRadius = avatarBackgroundHeight.constant / 2
        avatarBackground.layer.borderWidth = 1
        avatarBackground.layer.borderColor = UIColor.darkRed().cgColor
        avatarImageView.layer.cornerRadius = (avatarBackgroundHeight.constant - 8) / 2
        avatarImageView.clipsToBounds = true
    }
}
