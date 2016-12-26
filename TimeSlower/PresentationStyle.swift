//
//  PresentationStyle.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 12/18/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation

internal enum PresentationStyle {
    
    case push(navigationController: UINavigationController?)
    case present(presenter: UIViewController?)
    
}
