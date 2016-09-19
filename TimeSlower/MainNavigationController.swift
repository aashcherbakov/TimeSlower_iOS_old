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
    
    lazy var coreDataStack = CoreDataStack.self

    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitialController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        profile = fetchProfile()
        if viewControllers.first is ProfileEditingVC {
            if profile != nil {
                setupInitialController()
            }
        }
    }
    
    // MARK: - Private Functions
    
    fileprivate func setupInitialController() {
        let rootController: UIViewController
        
        if let profile = profile {
            let homeController: HomeViewController = ControllerFactory.createController()
            homeController.profile = profile
            rootController = homeController
        } else {
            let profileController: ProfileEditingVC = ControllerFactory.createController()
            rootController = profileController
        }
        
        setViewControllers([rootController], animated: false)
    }
    
    fileprivate func fetchProfile() -> Profile? {
        return coreDataStack.sharedInstance.fetchProfile()
    }
}
