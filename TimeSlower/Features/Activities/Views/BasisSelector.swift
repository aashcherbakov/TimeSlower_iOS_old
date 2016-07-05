//
//  BasisSelector.swift
//  TimeSlower2
//
//  Created by Aleksander Shcherbakov on 7/17/15.
//  Copyright (c) 2015 1lastDay. All rights reserved.
//

import UIKit
import TimeSlowerKit
import ReactiveCocoa

/// UIControl subclass used to select activity basis on high level: Daily, Workdays or Weekends
class BasisSelector: UIControl {

    // MARK: - Properties
    
    @IBOutlet private(set) var view: UIView!
    @IBOutlet weak var dailyOptionView: BasisOptionView!
    @IBOutlet weak var workdaysOptionView: BasisOptionView!
    @IBOutlet weak var weekendsOptionView: BasisOptionView!
    
    var selectedIndex: Int? {
        didSet {
            sendActionsForControlEvents(.ValueChanged)
        }
    }
    
    private var basisOptionsViews: [BasisOptionView] = []
    
    // MARK: - Overridden Methods
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupDesign()
        setupEvents()
    }
    
    // MARK: - Internal Methods
    
    func updateSegmentedIndexForBasis(basis: Basis) {
        guard basis != .Random else {
            resetOptionViews(basisOptionsViews)
            return
        }
        
        selectedIndex = basis.rawValue
        resetButtonsForSelectedIndex(basis.rawValue)
        basisOptionsViews[basis.rawValue].optionSelected = true
    }
    
    // MARK: - Setup Methods
    
    private func setupDesign() {
        NSBundle.mainBundle().loadNibNamed("BasisSelector", owner: self, options: nil)
        bounds = view.bounds
        addSubview(view)
        
        dailyOptionView.setupForBasis("Daily")
        workdaysOptionView.setupForBasis("Workdays")
        weekendsOptionView.setupForBasis("Weekends")
        
        basisOptionsViews = [dailyOptionView, workdaysOptionView, weekendsOptionView]
    }

    private func setupEvents() {
        for optionView in basisOptionsViews {
            subscribeToValueChangeForOptionView(optionView)
        }
    }
    
    private func subscribeToValueChangeForOptionView(optionView: BasisOptionView) {
        optionView.rac_signalForControlEvents(.ValueChanged).toSignalProducer()
            .startWithNext { [weak self] (value) in
                guard let option = value as? BasisOptionView,
                    weakSelf = self else { return }
                
                if let optionIndex = weakSelf.basisOptionsViews.indexOf(option) {
                    weakSelf.selectedIndex = option.optionSelected ? optionIndex : nil
                    weakSelf.resetButtonsForSelectedIndex(optionIndex)
                }
        }
    }
    
    private func resetButtonsForSelectedIndex(index: Int) {
        var optionsToDeselect = basisOptionsViews
        if optionsToDeselect.count > index {
            optionsToDeselect.removeAtIndex(index)
        }
        resetOptionViews(optionsToDeselect)
    }
    
    private func resetOptionViews(optionViews: [BasisOptionView]) {
        for option in optionViews {
            option.optionSelected = false
        }
    }
}
