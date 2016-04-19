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
        case is MenuVC.Type: return "Main"
        case is MainScreenVC.Type: return "Main"
        case is EditActivityVC.Type: return "Activities"
        case is ProfileEditingVC.Type: return "Profile"

        default: return nil
        }
    }
}

