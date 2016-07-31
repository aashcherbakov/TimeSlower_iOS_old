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
    
    private var profile: Profile?
    
    lazy var coreDataStack = CoreDataStack.self

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        setupInitialController()
    }
    
    // MARK: - Private Functions
    
    private func setupInitialController() {
        let rootController: UIViewController
        if let profile = fetchProfile() {
            let homeController: HomeViewController = ControllerFactory.createController()
            homeController.profile = profile
            rootController = homeController
        } else {
            let profileController: ProfileEditingVC = ControllerFactory.createController()
            rootController = profileController
        }
        
        setViewControllers([rootController], animated: false)
    }
    
    private func fetchProfile() -> Profile? {
        return coreDataStack.sharedInstance.fetchProfile()
    }
}
