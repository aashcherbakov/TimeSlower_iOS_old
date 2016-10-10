//
//  File.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 2/21/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import UIKit
import ReactiveSwift
import Result

/// UITableViewCell subclass to turn on/off notifications for activity
class EditActivityNotificationsView: ObservableControl {
    
    // MARK: - Properties
    
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var notificationSwitch: UISwitch!
    @IBOutlet weak var textfieldView: TextfieldView!
    @IBOutlet weak var textfieldViewHeight: NSLayoutConstraint!
    
    /// Bool true if notification switch is on
    dynamic var selectedValue: NSNumber = true
    
    fileprivate var valueChangedSignal: SignalProducer<Any?, NoError>?
    
    // MARK: - Overridden Methods
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupXib()
        
        setupEvents()
        setupDesign()
    }
    
    override func valueSignal() -> SignalProducer<Any?, NoError>? {
        return valueChangedSignal
    }
    
    override func setInitialValue(_ value: AnyObject?) {
        if let value = value as? NSNumber {
            selectedValue = value
            updateTextFieldForSwitch(value.boolValue)
            notificationSwitch.isOn = value.boolValue
        }
    }
    
    // MARK: - Setup Methods
    
    fileprivate func setupXib() {
        Bundle.main.loadNibNamed(EditActivityNotificationsView.className, owner: self, options: nil)
        bounds = view.bounds
        addSubview(view)
    }
    
    fileprivate func setupDesign() {
        textfieldView.setupWithConfig(NotificationsTextfield())
        notificationSwitch.onTintColor = UIColor.purpleRed()
        notificationSwitch.isOn = true
        updateTextFieldForSwitch(notificationSwitch.isOn)
    }
    
    fileprivate func setupEvents() {
        
        let switchSignal = notificationSwitch.rac_signal(for: .valueChanged)
            .toSignalProducer()
            .map { (value) -> NSNumber? in
                guard let switcher = value as? UISwitch else { return nil }
                return switcher.isOn as NSNumber
            }
            .flatMapError { SignalProducer<Any?, NoError>(value: $0.code) }
        
        valueChangedSignal = switchSignal
        
        valueChangedSignal?.startWithResult { [weak self] (result) in
            guard let value = result.value as? Bool else { return }
            self?.selectedValue = value as NSNumber
            self?.updateTextFieldForSwitch(value)
        }
    }
    
    fileprivate func updateTextFieldForSwitch(_ on: Bool) {
        let text = on ? "on" : "off"
        textfieldView.setText(text)
    }
}
