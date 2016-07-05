//
//  BasisOptionView.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 6/19/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation

class BasisOptionView: UIControl {
    
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var selectedIndicatorImage: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var button: UIButton!
    
    private let selectedIcon = UIImage(named: "selectedIcon")
    private let deselectedIcon = UIImage(named: "deselectedIcon")
    
    dynamic var optionSelected = false {
        didSet {
            label.textColor = optionSelected ? UIColor.purpleRed() : UIColor.lightGray()
            selectedIndicatorImage.image = optionSelected ? selectedIcon : deselectedIcon
        }
    }
    
    // MARK: - Internal Functions
    
    func setupForBasis(basis: String) {
        label.text = basis
    }
    
    @IBAction func buttonTapped(sender: UIButton) {
        optionSelected = !optionSelected
        sendActionsForControlEvents(.ValueChanged)
    }
    
    // MARK: - Setup Functions
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupDesign()
    }
    
    private func setupDesign() {
        NSBundle.mainBundle().loadNibNamed("BasisOptionView", owner: self, options: nil)
        bounds = view.bounds
        addSubview(view)
    }
}