//
//  EditActivityStartTimeView.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 2/21/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import UIKit
import ReactiveCocoa
import TimeSlowerKit

/// UITableViewCell subclass to edit start time of activity
class EditActivityStartTimeView: ObservableControl {
    
    // MARK: - Properties
    
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var textfieldView: TextfieldView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var separatorLineHeight: NSLayoutConstraint!
    @IBOutlet weak var textfieldViewHeightConstraint: NSLayoutConstraint!
    private var shortDateFormatter: NSDateFormatter = {
        return DateManager.sharedShortDateFormatter()
    }()
    
    /// Selected date. Observable
    dynamic var selectedValue: NSDate?
    private var valueChangedSignal: SignalProducer<AnyObject?, NSError>?
    private var timer: Timer?
    
    // MARK: - Overridden Methods
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupXib()
        
        setupDesign()
        setupEvents()
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        print("Start time touched")
        super.touchesEnded(touches, withEvent: event)
        sendActionsForControlEvents(.TouchUpInside)

        textfieldView.setText(shortDateFormatter.stringFromDate(datePicker.date))
        if datePicker.date != selectedValue {
            selectedValue = datePicker.date
        }
    }
    
    override func valueSignal() -> SignalProducer<AnyObject?, NSError>? {
        return valueChangedSignal
    }
    
    override func setInitialValue(value: AnyObject?) {
        if let value = value as? NSDate {
            selectedValue = value
            datePicker.setDate(value, animated: false)
        }
    }
    
    // MARK: - Setup Methods
    
    private func setupXib() {
        NSBundle.mainBundle().loadNibNamed(EditActivityStartTimeView.className, owner: self, options: nil)
        bounds = view.bounds
        addSubview(view)
    }
    
    private func setupDesign() {
        textfieldView.setupWithConfig(StartTimeTextfield())
        separatorLineHeight.constant = kDefaultSeparatorHeight
    }
    
    private func setupEvents() {
        datePicker.rac_signalForControlEvents(.ValueChanged).toSignalProducer()
            .startWithNext { [weak self] (datePicker) in
                guard let picker = datePicker as? UIDatePicker else {
                    return
                }
                self?.selectedValue = picker.date
                self?.textfieldView.setText(self?.shortDateFormatter.stringFromDate(picker.date))
        }
        
        valueChangedSignal = delayedProducer()
    }
    
    private func delayedProducer() -> SignalProducer<AnyObject?, NSError> {
        return SignalProducer { [weak self] (observer, _) in
            
            self?.rac_valuesForKeyPath("selectedValue", observer: self)
                .startWith(self?.datePicker)
                .toSignalProducer()
                .on(completed: {
                        observer.sendCompleted()
                        self?.timer?.terminate()
                    },
                    next: { (value) in
                        if let value = value as? NSDate {
                            self?.textfieldView.setText(self?.shortDateFormatter.stringFromDate(value))
                        }

                        self?.timer?.terminate()
                        self?.timer = Timer(1) {
                            observer.sendNext(value)
                        }
                        
                        self?.timer?.start()
                })
                .start()
        }
    }
}