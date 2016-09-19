//
//  BasisSelector.swift
//  TimeSlower2
//
//  Created by Aleksander Shcherbakov on 7/17/15.
//  Copyright (c) 2015 1lastDay. All rights reserved.
//

import UIKit
import TimeSlowerKit
import ReactiveSwift

/// UIControl subclass used to select activity basis on high level: Daily, Workdays or Weekends
class BasisSelector: UIControl {

    // MARK: - Properties
    
    @IBOutlet fileprivate(set) var view: UIView!
    @IBOutlet weak var dailyOptionView: BasisOptionView!
    @IBOutlet weak var workdaysOptionView: BasisOptionView!
    @IBOutlet weak var weekendsOptionView: BasisOptionView!
    
    var selectedIndex: Int? {
        didSet {
            sendActions(for: .valueChanged)
        }
    }
    
    fileprivate var basisOptionsViews: [BasisOptionView] = []
    
    // MARK: - Overridden Methods
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupDesign()
        setupEvents()
    }
    
    // MARK: - Internal Methods
    
    func updateSegmentedIndexForBasis(_ basis: Basis) {
        guard basis != .random else {
            resetOptionViews(basisOptionsViews)
            return
        }
        
        selectedIndex = basis.rawValue
        resetButtonsForSelectedIndex(basis.rawValue)
        basisOptionsViews[basis.rawValue].optionSelected = true
    }
    
    // MARK: - Setup Methods
    
    fileprivate func setupDesign() {
        Bundle.main.loadNibNamed("BasisSelector", owner: self, options: nil)
        bounds = view.bounds
        addSubview(view)
        
        dailyOptionView.setupForBasis("Daily")
        workdaysOptionView.setupForBasis("Workdays")
        weekendsOptionView.setupForBasis("Weekends")
        
        basisOptionsViews = [dailyOptionView, workdaysOptionView, weekendsOptionView]
    }

    fileprivate func setupEvents() {
        for optionView in basisOptionsViews {
            subscribeToValueChangeForOptionView(optionView)
        }
    }
    
    fileprivate func subscribeToValueChangeForOptionView(_ optionView: BasisOptionView) {
//        optionView.rac_signalForControlEvents(.ValueChanged).toSignalProducer()
//            .startWithNext { [weak self] (value) in
//                guard let option = value as? BasisOptionView,
//                    let weakSelf = self else { return }
//                
//                if let optionIndex = weakSelf.basisOptionsViews.indexOf(option) {
//                    weakSelf.selectedIndex = option.optionSelected ? optionIndex : nil
//                    weakSelf.resetButtonsForSelectedIndex(optionIndex)
//                }
//        }
    }
    
    fileprivate func resetButtonsForSelectedIndex(_ index: Int) {
        var optionsToDeselect = basisOptionsViews
        if optionsToDeselect.count > index {
            optionsToDeselect.remove(at: index)
        }
        resetOptionViews(optionsToDeselect)
    }
    
    fileprivate func resetOptionViews(_ optionViews: [BasisOptionView]) {
        for option in optionViews {
            option.optionSelected = false
        }
    }
}
