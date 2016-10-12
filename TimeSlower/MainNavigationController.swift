//
//  MainNavigationController.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 7/30/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import UIKit
import TimeSlowerKit

/// UINavigationController subclass responsible for setting up initial controller on launch.
class MainNavigationController: UINavigationController {
    
    fileprivate var profile: Profile?
    fileprivate let dataStore = DataStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupInitialController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        profile = fetchProfile()
        resetInitialControllerIfNeeded()
    }
    
    // MARK: - Private Functions
    
    fileprivate func setupInitialController() {
        let rootController: UIViewController
        
        if let profile = profile {
            rootController = homeViewController(withProfile: profile)
        } else {
            rootController = profileEditController()
        }
        
        setViewControllers([rootController], animated: false)
    }
    
    fileprivate func fetchProfile() -> Profile? {
        let profile: Profile? = dataStore.retrieve("")
        return profile
    }
    
    private func resetInitialControllerIfNeeded() {
        if viewControllers.first is ProfileEditingVC && profile != nil {
            setupInitialController()
        }
    }
    
    private func homeViewController(withProfile profile: Profile) -> UIViewController {
        let homeController: HomeViewController = ControllerFactory.createController()
        homeController.profile.value = profile
        return homeController
    }
    
    private func profileEditController() -> UIViewController {
        let profileController: ProfileEditingVC = ControllerFactory.createController()
        return profileController

    }
}
