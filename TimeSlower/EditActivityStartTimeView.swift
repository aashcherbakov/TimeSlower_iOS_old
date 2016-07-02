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
class EditActivityStartTimeView: UIControl {
    
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
    
    // MARK: - Overridden Methods
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupXib()
        
        setupDesign()
        setupEvents()
    }
    
    func setupXib() {
        NSBundle.mainBundle().loadNibNamed(EditActivityStartTimeView.className, owner: self, options: nil)
        bounds = view.bounds
        addSubview(view)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        sendActionsForControlEvents(.TouchUpInside)

        textfieldView.setText(shortDateFormatter.stringFromDate(datePicker.date))
        if datePicker.date != selectedValue {
            selectedValue = datePicker.date
        }
    }
    
    // MARK: - Setup Methods
    
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
        
        self.rac_valuesForKeyPath("selectedValue", observer: self).toSignalProducer()
            .startWithNext { [weak self] (value) in
                guard let value = value as? NSDate else { return }
                self?.textfieldView.setText(self?.shortDateFormatter.stringFromDate(value))
        }
    }
}