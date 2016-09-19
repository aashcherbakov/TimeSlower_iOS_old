//
//  ContollerFactory.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 2/6/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation

/**
 *  Protocol that unites UIViewControllers and alows to use generics for creation
 */
protocol Instantiatable { }

extension UIViewController: Instantiatable { }

/**
 *  Struct that alows simple creation of controllers using generics
 */
struct ControllerFactory {
    
    fileprivate struct Constants {
        static let activities = "Activities"
        static let menu = "Menu"
        static let profile = "Profile"
        static let main = "Main"
        static let motivaton = "Motivation"
    }
    
    /**
     Creates controller of specified type from appropriate storyboard
     
     - returns: controller of specified type
     */
    static func createController<T: Instantiatable>() -> T {
        guard let storyboard = storyboardForType(T.self) else {
            fatalError("Controller \(String(describing: T.self)) should be instantiated")
        }
        
        guard let controller = storyboard.instantiateViewController(withIdentifier: String(describing: T.self)) as? T else {
            fatalError("Controller \(String(describing: T.self)) should be instantiated")
        }
        
        return controller 
    }
    
    fileprivate static func storyboardForType<T>(_ type: T) -> UIStoryboard? {
        if let storyboardId = storyboardId(forType: type) {
            return UIStoryboard(name: storyboardId, bundle: nil)
        } else {
            return nil
        }
    }
    
    fileprivate static func storyboardId<T>(forType type: T) -> String? {
        switch type {
        case is MenuVC.Type: return Constants.menu
        case is MainScreenVC.Type: return Constants.main
        case is EditActivityVC.Type: return Constants.activities
        case is ListOfActivitiesVC.Type: return Constants.activities
        case is ProfileEditingVC.Type: return Constants.profile
        case is ProfileStatsVC.Type: return Constants.profile
        case is MotivationViewController.Type: return Constants.motivaton
        case is HomeViewController.Type: return Constants.main
        case is ActivityStatsVC.Type: return Constants.activities

        default: return nil
        }
    }
}

