//
//  GenderSelector.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 12/31/15.
//  Copyright © 2015 Oleksandr Shcherbakov. All rights reserved.
//

import UIKit

class GenderSelector: UIControl {
    
    @IBOutlet private weak var view: UIView!
    @IBOutlet private weak var femaleButton: UIButton!
    @IBOutlet private weak var maleButton: UIButton!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupXib()
    }
    
    private func setupXib() {
        NSBundle.mainBundle().loadNibNamed("GenderSelector", owner: self, options: nil)
        bounds = view.bounds
        addSubview(view)
    }
    
    /// Returns 0 for male, 1 for female and nil if none is selected
    func selectedGender() -> Int? {
        if maleButton.selected {
            return 0
        } else if femaleButton.selected {
            return 1
        } else {
            return nil
        }
    }
    
    /// Sets male (0) or female (1) button selected
    func setSelectedGender(selected: Int) {
        switch selected {
        case 0: maleButton.selected = true
        case 1: femaleButton.selected = true
        default: return
        }
    }

    @IBAction private func genderButtonTapped(sender: UIButton) {
        sender.selected = !sender.selected
        
        if sender.selected {
            if sender.tag == 0 { // male button
                femaleButton.selected = !maleButton.selected
            } else {
                maleButton.selected = !femaleButton.selected
            }
        }
    }
}