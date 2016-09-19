//
//  EditActivityNameView.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 2/20/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation

import UIKit
import ReactiveSwift
import Result

/**
 UIView subclass used to enter/edit activity name. Contains TextfieldView to
 collect data and, in expanded state, - DefaultActivitySelector.
 */
class EditActivityNameView: ObservableControl {
    
    @IBOutlet weak var textFieldView: TextfieldView!
    @IBOutlet weak var defaultActivitySelectorView: DefaultActivitySelector!
    @IBOutlet weak var separatorLineHeight: NSLayoutConstraint!
    @IBOutlet var view: UIView!

    dynamic var selectedValue: String?
    fileprivate var valueChangedSignal: SignalProducer<AnyObject?, NSError>?

    // MARK: - Overridden
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupXib()
        setupEvents()
        setupDesign()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        defaultActivitySelectorView.setupCollectionViewItemSize()
    }
    
    override func valueSignal() -> SignalProducer<AnyObject?, NSError>? {
        return valueChangedSignal
    }
    
    override func setInitialValue(_ value: AnyObject?) {
        if let value = value as? String {
            selectedValue = value
        }
    }
    
    // MARK: - Private Methods
    
    fileprivate func setupXib() {
        Bundle.main.loadNibNamed("EditActivityNameView", owner: self, options: nil)
        bounds = view.bounds
        addSubview(view)
    }
    
    fileprivate func setupEvents() {
        
        let signal = rac_valuesForKeyPath("selectedValue", observer: self).toSignalProducer()
        
        valueChangedSignal = signal
        
        valueChangedSignal?.startWithNext { [weak self] (value) in
            guard let value = value as? String else { return }
            self?.textFieldView.setText(value)
        }
        
        defaultActivitySelectorView.rac_signalForControlEvents(.ValueChanged).toSignalProducer()
            .startWithNext { [weak self] (_) in
                guard let name = self?.defaultActivitySelectorView.selectedActivityName else { return }
                self?.sendActionsForControlEvents(.TouchUpInside)
                self?.selectedValue = name
        }
        
        textFieldView.textField.delegate = self
    }
    
    fileprivate func setupDesign() {
        textFieldView.setupWithConfig(NameTextfield())
        separatorLineHeight.constant = kDefaultSeparatorHeight
    }
}

extension EditActivityNameView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendActions(for: .touchUpInside)
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.becomeFirstResponder()
        sendActions(for: .touchUpInside)
    }
}
