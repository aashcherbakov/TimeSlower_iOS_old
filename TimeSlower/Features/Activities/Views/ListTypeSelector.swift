//
//  ListTypeSelector.swift
//  TimeSlower2
//
//  Created by Aleksander Shcherbakov on 7/16/15.
//  Copyright (c) 2015 1lastDay. All rights reserved.
//

import UIKit

class ListTypeSelector: UIControl {

    @IBOutlet weak var forTodayIcon: UIImageView!
    @IBOutlet weak var fullListIcon: UIImageView!
    @IBOutlet weak var forTodayLabel: UILabel!
    @IBOutlet weak var fullListLabel: UILabel!
    
    var selectedSegmentIndex: Int! {
        didSet {
            configureButtons(selectedSegmentIndex!)
            sendActionsForControlEvents(UIControlEvents.ValueChanged)
        }
    }

    @IBOutlet var view: UIView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupXib()
    }
    
    func setupXib() {
        NSBundle.mainBundle().loadNibNamed("ListTypeSelector", owner: self, options: nil)
        bounds = view.bounds
        addSubview(view)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first!
        let touchLocation = touch.locationInView(self)
        selectedSegmentIndex = (touchLocation.x < view.frame.width / 2) ? 0 : 1
    }
    
    func configureButtons(type: Int) {
        let forTodayImage = type == 0 ? "selectedIcon" : "deselectedIcon"
        let fullListImage = type == 1 ? "selectedIcon" : "deselectedIcon"
        
        forTodayLabel.textColor = type == 0 ? UIColor.purpleRed() : UIColor.darkGray()
        fullListLabel.textColor = type == 1 ? UIColor.purpleRed() : UIColor.darkGray()
        
        forTodayIcon.image = UIImage(named: forTodayImage)
        fullListIcon.image = UIImage(named: fullListImage)
    }


}
