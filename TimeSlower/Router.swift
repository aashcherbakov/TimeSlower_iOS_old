//
//  Router.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 12/17/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation
import TimeSlowerKit

internal struct Router {
    
    typealias EditActivity = (profile: Profile, activity: Activity?)
    
    func route(to destination: Destination, style: PresentationStyle) {
        let destinationController = controller(for: destination)
        return route(to: destinationController, style: style)
    }
    
    func controller(for destination: Destination) -> UIViewController {
        switch destination {
        case .home(profile: let profile):
            return homeViewController(with: profile)
        case .editActivity(activity: (let profile, let activity)):
            return editActivity(profile: profile, activity: activity)
        case .menu(profile: let profile):
            return menu(with: profile)
        case .editProfile(profile: let profile):
            return editProfile(profile)
        case .profileStats(profile: let profile):
            return profileStats(profile)
        case .activityStats(activity: let activity):
            return activityStats(activity)
        case .motivation(activity: let activity):
            return motivation(for: activity)
        case .activities(profile: let profile):
            return activitiesList(for: profile)
        }
    }
    
    // MARK: - Private functions
    
    private func route(to viewController: UIViewController, style: PresentationStyle) {
        switch style {
        case .push(let navigationController):
            navigationController?.pushViewController(viewController, animated: true)
        case .present(let presenter):
            presenter?.present(viewController, animated: true, completion: nil)
        }
    }
    
    private func homeViewController(with profile: Profile) -> HomeViewController {
        let controller: HomeViewController = ControllerFactory.createController()
        controller.setup(with: profile)
        return controller
    }
    
    private func menu(with profile: Profile) -> MenuVC {
        let controller: MenuVC = ControllerFactory.createController()
        controller.setup(with: profile)
        return controller
    }
    
    private func editActivity(profile: Profile, activity: Activity?) -> EditActivityVC {
        let controller: EditActivityVC = ControllerFactory.createController()
        controller.setup(with: (profile, activity))
        return controller
    }
    
    private func editProfile(_ profile: Profile?) -> ProfileEditingVC {
        let controller: ProfileEditingVC = ControllerFactory.createController()
        controller.setup(with: profile)
        return controller
    }
    
    private func profileStats(_ profile: Profile) -> ProfileStatsVC {
        let controller: ProfileStatsVC = ControllerFactory.createController()
        controller.setup(with: profile)
        return controller
    }
    
    private func activityStats(_ activity: Activity) -> ActivityStatsVC {
        let controller: ActivityStatsVC = ControllerFactory.createController()
        controller.setup(with: activity)
        return controller
    }
    
    private func motivation(for activity: Activity) -> MotivationViewController {
        let controller: MotivationViewController = ControllerFactory.createController()
        controller.setup(with: activity)
        return controller
    }
    
    private func activitiesList(for profile: Profile) -> ActivitiesList {
        let controller: ActivitiesList = ControllerFactory.createController()
        controller.setup(with: profile)
        return controller
    }
    
}

