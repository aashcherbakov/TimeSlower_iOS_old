//
//  FaleControllerWithTextfieldView.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 2/7/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation
@testable import TimeSlower
import UIKit

class FakeControllerWithTextfieldView: UIViewController, FakeController {
    
    @IBOutlet weak var textfieldView: TextfieldView!
}