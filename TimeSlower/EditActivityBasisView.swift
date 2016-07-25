//
//  EditActivityBasisView.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 2/20/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import UIKit
import ReactiveCocoa
import TimeSlowerKit

/**
 UITableViewCell subclass that allows user to select activity basis.
 Includes BasisSelector and DaySelector instances.
 */
class EditActivityBasisView: ObservableControl {
    
    // MARK: - Properties
    
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var separatorLineHeight: NSLayoutConstraint!
    @IBOutlet weak var daySelector: DaySelector!
    @IBOutlet weak var basisSelector: BasisSelector!
    @IBOutlet weak var textFieldView: TextfieldView!
    @IBOutlet weak var textFieldViewHeightConstraint: NSLayoutConstraint!
    
    var selectedBasis: Basis? {
        didSet {
            if let selectedBasis = selectedBasis {
                daySelector.selectedBasis = selectedBasis
            }
            
            textFieldView.setText(selectedBasis?.description())
        }
    }
    
    private var timer: Timer?
    
    /// Value that is being tracked from EditActivityViewController
    dynamic var selectedValue: [Int]?
    private var valueChangedSignal: SignalProducer<AnyObject?, NSError>?
    
    // MARK: - Overridden Methods
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupXib()
        setupEvents()
        setupDesign()
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        sendActionsForControlEvents(.TouchUpInside)
    }
    
    override func valueSignal() -> SignalProducer<AnyObject?, NSError>? {
        return valueChangedSignal
    }
    
    override func setInitialValue(value: AnyObject?) {
        if let value = value as? [Int] {
            selectedValue = value
            let basis = DateManager.basisFromDays(value)
            textFieldView.setText(basis.description())
            basisSelector.updateSegmentedIndexForBasis(basis)
            daySelector.displayValue(value)
        }
    }
    
    // MARK: - Setup Methods
    
    private func setupXib() {
        NSBundle.mainBundle().loadNibNamed(EditActivityBasisView.className, owner: self, options: nil)
        bounds = view.bounds
        addSubview(view)
    }
    
    private func setupDesign() {
        textFieldView.setupWithConfig(BasisTextfield())
        separatorLineHeight.constant = kDefaultSeparatorHeight
    }
    
    private func setupEvents() {
        valueChangedSignal = delayedValueSignalProducer()
        
        basisSelector.rac_signalForControlEvents(.ValueChanged).toSignalProducer()
            .startWithNext { [weak self] (value) in
                guard let selector = value as? BasisSelector else { return }
                self?.updateBasis(selector.selectedIndex)
        }
        
        daySelector.rac_signalForControlEvents(.ValueChanged).toSignalProducer()
            .startWithNext { [weak self] (value) in
                guard let selector = value as? DaySelector else { return }
                
                self?.basisSelector.updateSegmentedIndexForBasis(selector.selectedBasis)
                self?.selectedBasis = selector.selectedBasis
                self?.selectedValue = Array(selector.selectedDays)
        }
    }
    
    private func delayedValueSignalProducer() -> SignalProducer<AnyObject?, NSError> {
        return SignalProducer { [weak self] (observer, _) in
            
            self?.rac_valuesForKeyPath("selectedValue", observer: self)
                .toSignalProducer()
                .on(completed: {
                        observer.sendCompleted()
                        self?.timer?.terminate()
                    },
                    next: { (value) in
                        self?.timer?.terminate()
                        self?.timer = Timer(1) {
                            observer.sendNext(value)
                        }
                        
                        self?.timer?.start()
                })
                .start()
        }
    }

    private func updateBasis(index: Int?) {
        guard let index = index else { return }
        if let newBasis = Basis(rawValue: index) where selectedBasis != newBasis {
            daySelector.selectedBasis = newBasis
            selectedBasis = newBasis
            selectedValue = DateManager.daysFromBasis(newBasis)
            textFieldView.setText(newBasis.description())
        }
    }
}

