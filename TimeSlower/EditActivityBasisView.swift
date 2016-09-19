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
    fileprivate var valueChangedSignal: SignalProducer<AnyObject?, NSError>?
    
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
    
    override func valueSignal() -> SignalProducer<AnyObject?, NSError>? {
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
//        valueChangedSignal = delayedValueSignalProducer()
        
//        basisSelector.rac_signalForControlEvents(.ValueChanged).toSignalProducer()
//            .startWithNext { [weak self] (value) in
//                guard let selector = value as? BasisSelector else { return }
//                self?.updateBasis(selector.selectedIndex)
//        }
//        
//        daySelector.rac_signalForControlEvents(.ValueChanged).toSignalProducer()
//            .startWithNext { [weak self] (value) in
//                guard let selector = value as? DaySelector else { return }
//                
//                self?.basisSelector.updateSegmentedIndexForBasis(selector.selectedBasis)
//                self?.selectedBasis = selector.selectedBasis
//                self?.selectedValue = Array(selector.selectedDays)
//        }
    }
    
//    fileprivate func delayedValueSignalProducer() -> SignalProducer<AnyObject?, NSError> {
//        return SignalProducer { [weak self] (observer, _) in
//            
//            self?.rac_valuesForKeyPath("selectedValue", observer: self)
//                .toSignalProducer()
//                .on(completed: {
//                        observer.sendCompleted()
//                        self?.timer?.terminate()
//                    },
//                    next: { (value) in
//                        self?.timer?.terminate()
//                        self?.timer = Timer(1) {
//                            observer.sendNext(value)
//                        }
//                        
//                        self?.timer?.start()
//                })
//                .start()
//        }
//    }

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

