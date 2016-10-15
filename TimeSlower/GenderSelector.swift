//
//  GenderSelector.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 12/31/15.
//  Copyright © 2015 Oleksandr Shcherbakov. All rights reserved.
//

import UIKit

class GenderSelector: UIControl {
    
    @IBOutlet fileprivate weak var view: UIView!
    @IBOutlet fileprivate weak var femaleButton: UIButton!
    @IBOutlet fileprivate weak var maleButton: UIButton!
    
    var selectedSegmentIndex: Int?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupXib()
    }
    
    fileprivate func setupXib() {
        Bundle.main.loadNibNamed("GenderSelector", owner: self, options: nil)
        bounds = view.bounds
        addSubview(view)
    }
    
    /// Returns 0 for male, 1 for female and nil if none is selected
    func selectedGender() -> Int? {
        if maleButton.isSelected {
            return 0
        } else if femaleButton.isSelected {
            return 1
        } else {
            return nil
        }
    }
    
    /// Sets male (0) or female (1) button selected
    func setSelectedGender(_ selected: Int) {
        switch selected {
        case 0: maleButton.isSelected = true
        case 1: femaleButton.isSelected = true
        default: return
        }
    }

    @IBAction fileprivate func genderButtonTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            if sender.tag == 0 { // male button
                femaleButton.isSelected = !maleButton.isSelected
            } else {
                maleButton.isSelected = !femaleButton.isSelected
            }
        }
        
        selectedSegmentIndex = sender.tag
        sendActions(for: .valueChanged)
    }
}
