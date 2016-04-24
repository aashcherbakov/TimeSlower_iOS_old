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
    
    private struct Constants {
        static let activities = "Activities"
        static let menu = "Menu"
        static let profile = "Profile"
        static let main = "Main"
    }
    
    /**
     Creates controller of specified type from appropriate storyboard
     
     - returns: controller of specified type
     */
    static func createController<T: Instantiatable>() -> T {
        guard let storyboard = storyboardForType(T) else {
            fatalError("Controller \(String(T)) should be instantiated")
        }
        
        guard let controller = storyboard.instantiateViewControllerWithIdentifier(String(T)) as? T else {
            fatalError("Controller \(String(T)) should be instantiated")
        }
        
        return controller 
    }
    
    private static func storyboardForType<T>(type: T) -> UIStoryboard? {
        if let storyboardId = storyboardId(forType: type) {
            return UIStoryboard(name: storyboardId, bundle: nil)
        } else {
            return nil
        }
    }
    
    private static func storyboardId<T>(forType type: T) -> String? {
        switch type {
        case is MenuVC.Type: return Constants.menu
        case is MainScreenVC.Type: return Constants.main
        case is EditActivityVC.Type: return Constants.activities
        case is ListOfActivitiesVC.Type: return Constants.activities
        case is ActivityMotivationVC.Type: return Constants.activities
        case is ProfileEditingVC.Type: return Constants.profile

        default: return nil
        }
    }
}

