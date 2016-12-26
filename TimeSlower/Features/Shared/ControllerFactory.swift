//
//  ContollerFactory.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 2/6/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation
import TimeSlowerKit

/**
 *  Protocol that unites UIViewControllers and alows to use generics for creation
 */
protocol Instantiatable {
    
    associatedtype SetupObject
    
    func setup(with object: SetupObject)
}

/**
 *  Struct that alows simple creation of controllers using generics
 */
struct ControllerFactory {
    
    fileprivate struct Storyboard {
        static let activities = "Activities"
        static let menu = "Menu"
        static let profile = "Profile"
        static let main = "Main"
        static let motivation = "Motivation"
        static let home = "Home"
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
    
    static func createController<T>(_ type: T.Type) -> T where T: Instantiatable {
        print(type)
        guard let storyboard = storyboardForType(type) else {
            fatalError("Controller \(String(describing: type)) should be instantiated")
        }
        
        guard let controller = storyboard.instantiateViewController(withIdentifier: String(describing: type)) as? T else {
            fatalError("Controller \(String(describing: type)) should be instantiated")
        }
        
        return controller
    }
    
    private static func storyboardForType<T>(_ type: T) -> UIStoryboard? {
        if let storyboardId = storyboardId(forType: type) {
            return UIStoryboard(name: storyboardId, bundle: nil)
        } else {
            return nil
        }
    }
    
    private static func storyboardId<T>(forType type: T) -> String? {
        switch type {
        case is MenuViewController.Type: return Storyboard.menu
        case is EditActivityVC.Type: return Storyboard.activities
        case is ActivitiesList.Type: return Storyboard.activities
        case is ProfileEditingVC.Type: return Storyboard.profile
        case is ProfileStatsVC.Type: return Storyboard.profile
        case is MotivationViewController.Type: return Storyboard.motivation
        case is HomeViewController.Type: return Storyboard.home
        case is ActivityStatsVC.Type: return Storyboard.activities

        default: return nil
        }
    }
}

