//
//  EditActivityBasisView.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 2/20/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import UIKit
import ReactiveSwift
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
    
    fileprivate var timer: Timer?
    
    /// Value that is being tracked from EditActivityViewController
    dynamic var selectedValue: [Int]?
    fileprivate var valueChangedSignal: SignalProducer<Any?, NSError>?
    
    // MARK: - Overridden Methods
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupXib()
        setupEvents()
        setupDesign()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        sendActions(for: .touchUpInside)
    }
    
    override func valueSignal() -> SignalProducer<Any?, NSError>? {
        return valueChangedSignal
    }
    
    override func setInitialValue(_ value: AnyObject?) {
        if let value = value as? [Int] {
            selectedValue = value
            let basis = Basis.basisFromDays(value)
            textFieldView.setText(basis.description())
            basisSelector.updateSegmentedIndexForBasis(basis)
            daySelector.displayValue(value)
        }
    }
    
    // MARK: - Setup Methods
    
    fileprivate func setupXib() {
        Bundle.main.loadNibNamed(EditActivityBasisView.className, owner: self, options: nil)
        bounds = view.bounds
        addSubview(view)
    }
    
    fileprivate func setupDesign() {
        textFieldView.setupWithConfig(BasisTextfield())
        separatorLineHeight.constant = kDefaultSeparatorHeight
    }
    
    fileprivate func setupEvents() {
        valueChangedSignal = delayedValueSignalProducer()
        
        basisSelector.rac_signal(for: .valueChanged).toSignalProducer()
            .startWithResult { [weak self] (result) in
                guard let selector = result.value as? BasisSelector else { return }
                self?.updateBasis(selector.selectedIndex)
        }
        
        daySelector.rac_signal(for: .valueChanged).toSignalProducer()
            .startWithResult { [weak self] (result) in
                guard let selector = result.value as? DaySelector else { return }
                
                self?.basisSelector.updateSegmentedIndexForBasis(selector.selectedBasis)
                self?.selectedBasis = selector.selectedBasis
                self?.selectedValue = Array(selector.selectedDays)
        }
    }
    
    fileprivate func delayedValueSignalProducer() -> SignalProducer<Any?, NSError> {
        return SignalProducer { [weak self] (observer, _) in
            
            self?.rac_values(forKeyPath: "selectedValue", observer: self)
                .toSignalProducer()
                .on(starting: { (value) in
                    self?.timer?.terminate()
                    self?.timer = Timer(1) {
                        observer.send(value: value)
                    }
                    
                    self?.timer?.start()
                    },
                    completed: {
                        observer.sendCompleted()
                        self?.timer?.terminate()
                })
                .start()
        }
    }

    fileprivate func updateBasis(_ index: Int?) {
        guard let index = index else { return }
        if let newBasis = Basis(rawValue: index) , selectedBasis != newBasis {
            daySelector.selectedBasis = newBasis
            selectedBasis = newBasis
            selectedValue = Basis.daysFromBasis(newBasis)
            textFieldView.setText(newBasis.description())
        }
    }
}

