//
//  EditActivityStartTimeView.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 2/21/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import UIKit
import ReactiveSwift
import TimeSlowerKit
import Result

/// UITableViewCell subclass to edit start time of activity
class EditActivityStartTimeView: ObservableControl {
    
    // MARK: - Properties
    
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var textfieldView: TextfieldView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var separatorLineHeight: NSLayoutConstraint!
    @IBOutlet weak var textfieldViewHeightConstraint: NSLayoutConstraint!
    fileprivate let shortDateFormatter = StaticDateFormatter.shortTimeNoDateFormatter
    
    /// Selected date. Observable
    dynamic var selectedValue: Date?
    fileprivate var valueChangedSignal: SignalProducer<Any?, NoError>?
    fileprivate var timer: Timer?
    
    // MARK: - Overridden Methods
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupXib()
        
        setupDesign()
        setupEvents()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        sendActions(for: .touchUpInside)

        textfieldView.setText(shortDateFormatter.string(from: datePicker.date))
        if datePicker.date != selectedValue {
            selectedValue = datePicker.date
        }
    }
    
    override func valueSignal() -> SignalProducer<Any?, NoError>? {
        return valueChangedSignal
    }
    
    override func setInitialValue(_ value: AnyObject?) {
        if let value = value as? Date {
            selectedValue = value
            datePicker.setDate(value, animated: false)
        }
    }
    
    // MARK: - Setup Methods
    
    fileprivate func setupXib() {
        Bundle.main.loadNibNamed(EditActivityStartTimeView.className, owner: self, options: nil)
        bounds = view.bounds
        addSubview(view)
    }
    
    fileprivate func setupDesign() {
        textfieldView.setupWithConfig(StartTimeTextfield())
        separatorLineHeight.constant = kDefaultSeparatorHeight
    }
    
    fileprivate func setupEvents() {
        datePicker.rac_signal(for: .valueChanged).toSignalProducer()
            .startWithResult { [weak self] (datePicker) in
                guard let picker = datePicker.value as? UIDatePicker else {
                    return
                }
                self?.selectedValue = picker.date
                self?.textfieldView.setText(self?.shortDateFormatter.string(from: picker.date))
        }
        
        valueChangedSignal = delayedProducer()
    }
    
    fileprivate func delayedProducer() -> SignalProducer<Any?, NoError> {
        return SignalProducer { [weak self] (observer, _) in
            
            self?.rac_values(forKeyPath: "selectedValue", observer: self)
                .start(with: self?.datePicker)
                .toSignalProducer()
                .on(value: { (value) in
                    if let value = value as? Date {
                        self?.textfieldView.setText(self?.shortDateFormatter.string(from: value as Date))
                    }
                    
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
}
