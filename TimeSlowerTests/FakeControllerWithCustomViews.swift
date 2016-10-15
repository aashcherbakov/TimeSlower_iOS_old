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

class FakeControllerWithCustomViews: UIViewController, FakeController {

    @IBOutlet weak var basisSelector: BasisSelector!
    @IBOutlet weak var daySelector: DaySelector!
    @IBOutlet weak var textfieldView: TextfieldView!
    @IBOutlet weak var editActivityNameView: EditActivityNameView!
    @IBOutlet weak var editActivityBasisView: EditActivityBasisView!
    @IBOutlet weak var motivationControl: MotivationControl!
}
