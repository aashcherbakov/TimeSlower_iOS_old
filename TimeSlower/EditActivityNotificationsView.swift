//
//  File.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 2/21/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import UIKit
import ReactiveCocoa

/// UITableViewCell subclass to turn on/off notifications for activity
class EditActivityNotificationsView: ObservableControl {
    
    // MARK: - Properties
    
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var notificationSwitch: UISwitch!
    @IBOutlet weak var textfieldView: TextfieldView!
    @IBOutlet weak var textfieldViewHeight: NSLayoutConstraint!
    
    /// Bool true if notification switch is on
    dynamic var selectedValue: NSNumber = true
    
    private var valueChangedSignal: SignalProducer<AnyObject?, NSError>?
    
    // MARK: - Overridden Methods
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupXib()
        
        setupEvents()
        setupDesign()
    }
    
    override func valueSignal() -> SignalProducer<AnyObject?, NSError>? {
        return valueChangedSignal
    }
    
    override func setInitialValue(value: AnyObject?) {
        if let value = value as? NSNumber {
            selectedValue = value
            updateTextFieldForSwitch(value.boolValue)
            notificationSwitch.on = value.boolValue
        }
    }
    
    // MARK: - Setup Methods
    
    private func setupXib() {
        NSBundle.mainBundle().loadNibNamed(EditActivityNotificationsView.className, owner: self, options: nil)
        bounds = view.bounds
        addSubview(view)
    }
    
    private func setupDesign() {
        textfieldView.setupWithConfig(NotificationsTextfield())
        notificationSwitch.onTintColor = UIColor.purpleRed()
        notificationSwitch.on = true
        updateTextFieldForSwitch(notificationSwitch.on)
    }
    
    private func setupEvents() {
        valueChangedSignal = notificationSwitch.rac_signalForControlEvents(.ValueChanged).startWith(notificationSwitch).toSignalProducer()
        valueChangedSignal?.startWithNext { [weak self] (value) in
            guard let switcher = value as? UISwitch else { return }
            self?.selectedValue = switcher.on
            self?.updateTextFieldForSwitch(switcher.on)
        }
    }
    
    private func updateTextFieldForSwitch(on: Bool) {
        let text = on ? "on" : "off"
        textfieldView.setText(text)
    }
}
