//
//  MainNavigationController.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 11/6/15.
//  Copyright © 2015 Oleksandr Shcherbakov. All rights reserved.
//

import UIKit

/// Root class responsible for loading first view of application
class MainNavigationController: UINavigationController {

    private lazy var mainStatsViewController: MainScreenVC? = {
        return self.statsStoryboard.instantiateViewControllerWithIdentifier("MainScreenVC") as? MainScreenVC
    }()
    
    private lazy var statsStoryboard: UIStoryboard = {
        return UIStoryboard(name: "Stats", bundle: nil)
    }()
    
    // MARK: - ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let mainStatsVC = self.mainStatsViewController {
            self.viewControllers = [mainStatsVC]
        }
    }
}
