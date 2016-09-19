//
//  TypeSelector.swift
//  TimeSlower2
//
//  Created by Aleksander Shcherbakov on 7/16/15.
//  Copyright (c) 2015 1lastDay. All rights reserved.
//

import UIKit
import TimeSlowerKit

class TypeSelector: UIControl {

    struct Constants {
        static let horizontalOffsetScale: CGFloat = 0.2
    }
    
    @IBOutlet var view: UIView!
    
    var selectedSegmentIndex: Int? {
        didSet {
            if let selectedIndex = selectedSegmentIndex {
                configureButtons(selectedIndex)
            } else {
                deselectAllButtons()
            }
            sendActions(for: UIControlEvents.valueChanged)
        }
    }
    
    @IBOutlet weak var goalsButton: UIButton!
    @IBOutlet weak var routinesButton: UIButton!
    @IBOutlet weak var routinesButtonLabel: UILabel!
    @IBOutlet weak var goalsButtonLabel: UILabel!
    
    @IBOutlet weak var routinesOffset: NSLayoutConstraint!
    @IBOutlet weak var goalsOffset: NSLayoutConstraint!
    @IBOutlet weak var separatorHeight: NSLayoutConstraint!
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupXib()
    }
    
    func setupXib() {        
        Bundle.main.loadNibNamed("TypeSelector", owner: self, options: nil)
        bounds = view.bounds
        addSubview(view)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let touchLocation = touch!.location(in: self)
        let newIndex = (touchLocation.x < view.frame.width / 2) ? 0 : 1
        if newIndex == selectedSegmentIndex {
            selectedSegmentIndex = nil
        } else {
            selectedSegmentIndex = newIndex
        }
    }
    
    func configureButtons(_ type: Int) {
        let routineImageName = type == 0 ? "routineIcon" : "routineIconGray"
        routinesButton.setImage(UIImage(named: routineImageName), for: UIControlState())
        let goalImageName = type == 1 ? "goalIcon" : "goalIconGray"
        goalsButton.setImage(UIImage(named: goalImageName), for: UIControlState())
    }
    
    func deselectAllButtons() {
        routinesButton.setImage(UIImage(named: "routineIconGray"), for: UIControlState())
        goalsButton.setImage(UIImage(named: "goalIconGray"), for: UIControlState())
    }
}
