//
//  FakeStoryboardLoader.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 2/7/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation
import UIKit
import TimeSlower

protocol FakeController {
    var view: UIView! { get }
}

class FakeStoryboardLoader {
    
    class func testViewController<T : FakeController>() -> T where T: NSObject {
        // Setup fake controller
        let storyboard = UIStoryboard(name: "FakeStoryboard", bundle: Bundle(for: T.classForCoder()))
        let controller = storyboard.instantiateViewController(withIdentifier: String(describing: T.self))
            as! T
        
        UIApplication.shared.keyWindow?.rootViewController = controller as? UIViewController
        let _ = controller.view // forces view to be loaded
        return controller
    }
}
