//
//  BasisSelector.swift
//  TimeSlower2
//
//  Created by Aleksander Shcherbakov on 7/17/15.
//  Copyright (c) 2015 1lastDay. All rights reserved.
//

import UIKit
import RxSwift

class BasisSelector: UIControl {

    var selectedSegmentIndex = Variable<Int?>(nil)
    
    @IBOutlet weak var weekendsLabel: UILabel!
    @IBOutlet weak var workdaysLabel: UILabel!
    @IBOutlet weak var dailyLabel: UILabel!
    @IBOutlet var view: UIView!
    @IBOutlet weak var dailySelectedIndicator: UIImageView!
    @IBOutlet weak var workdaysSelectedIndicator: UIImageView!
    @IBOutlet weak var weekendsSelectedIndicator: UIImageView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupXib()
    }
    
    func setupXib() {
        NSBundle.mainBundle().loadNibNamed("BasisSelector", owner: self, options: nil)
        bounds = view.bounds
        addSubview(view)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first
        let touchLocation = touch!.locationInView(self)
        
        if touchLocation.x < (view.frame.width / 3) {
            selectedSegmentIndex.value = 0
        } else if touchLocation.x > (view.frame.width / 3 * 2) {
            selectedSegmentIndex.value = 2
        } else {
            selectedSegmentIndex.value = 1
        }
        
        if let index = selectedSegmentIndex.value where index < 3 && index >= 0 {
            configureButtons(index)
        }
    }
    
    func configureButtons(type: Int) {
        
        let icons = [dailySelectedIndicator, workdaysSelectedIndicator, weekendsSelectedIndicator]
        let labels = [dailyLabel, workdaysLabel, weekendsLabel]
        for var i = 0; i < icons.count; i++ {
            if i == selectedSegmentIndex.value {
                icons[i].image = UIImage(named: "selectedIcon")
                labels[i].textColor = UIColor.purpleRed()
            } else {
                icons[i].image = UIImage(named: "deselectedIcon")
                labels[i].textColor = UIColor.lightGray()
            }
        }
    }
    
}
