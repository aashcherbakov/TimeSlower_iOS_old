//
//  EditActivityDurationView.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 2/21/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import UIKit

/// UITableViewCell subclass to edit duration of activity
class EditActivityDurationView: UIControl {
    
    /**
     Describes variants of time period: minutes and hours
     */
    enum Period: Int {
        case Minutes
        case Hours
        
        /**
         Literal lowercase transript of enum case
         
         - returns: String with literal transcript
         */
        func description() -> String {
            switch self {
            case .Minutes: return "minutes"
            case .Hours: return "hours"
            }
        }
    }
    
    /**
     Components of UIPickerView
     
     - Values:  represents numbers
     - Periods: represents time measurements: minutes or hours
     */
    enum Components: Int {
        case Values
        case Periods
    }
    
    private struct Constants {
        static let defaultDuration = 30
    }
    
    // MARK: - Properties
    
    /// Duration of activity in minutes. Observable.
    dynamic var selectedValue: NSNumber?
    
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var textfieldView: TextfieldView!
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var separatorLineHeight: NSLayoutConstraint!
    
    private let minutes = [5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55]
    private let hours = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    private var currentPeriod: Period = .Minutes

    // MARK: - Overriden Methods
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupXib()
        
        setupEvents()
        setupDesign()
    }
    
    func setupXib() {
        NSBundle.mainBundle().loadNibNamed(EditActivityDurationView.className, owner: self, options: nil)
        bounds = view.bounds
        addSubview(view)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)

        sendActionsForControlEvents(.TouchUpInside)
        updateValueFromPicker(pickerView)
    }
    
    // MARK: - Private Methods
    
    private func setupDesign() {
        textfieldView.setupWithConfig(DurationTextfield())
        separatorLineHeight.constant = kDefaultSeparatorHeight
        pickerView.selectRow(4, inComponent: Components.Values.rawValue, animated: false)
    }
    
    private func setupEvents() {
        pickerView.delegate = self
        pickerView.dataSource = self
    }
    
    private func updateValueFromPicker(pickerView: UIPickerView) {
        let values = getValuesFromPickerView(pickerView)
        if selectedValue != values.value {
            updateSelectedValueWithDuration(values.value, period: values.period)
        }
    }
    
    private func getValuesFromPickerView(pickerView: UIPickerView) -> (value: Int, period: Period) {
        let row = pickerView.selectedRowInComponent(Components.Values.rawValue)
        if let period = Period(rawValue: pickerView.selectedRowInComponent(Components.Periods.rawValue)) {
            let value = selectedValueForRow(row, period: period)
            return (value, period)
        } else {
            fatalError("DatePicker has only one component")
        }
    }
    
    private func updateSelectedValueWithDuration(duration: Int, period: Period) {
        selectedValue = duration
        textfieldView.setText("Duration: \(duration) \(period.description())")
    }
}

// MARK: - UIPickerViewDataSource
extension EditActivityDurationView: UIPickerViewDataSource {
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard let selectedComponent = Components(rawValue: component) else { return 0 }
        
        switch selectedComponent {
        case .Values: return currentPeriod == .Hours ? hours.count : minutes.count
        case .Periods: return 2
        }
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 2
    }
}

// MARK: - UIPickerViewDelegate
extension EditActivityDurationView: UIPickerViewDelegate {
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let selectedComponent = Components(rawValue: component) else { return nil }
        
        switch selectedComponent {
        case .Values: return titleForRow(row, selectedPeriod: currentPeriod)
        case .Periods: return titleForPeriodInRow(row)
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let selectedComponent = Components(rawValue: component) else { return }
       
        if let selectedPeriod = Period(rawValue: row) where selectedComponent == .Periods {
            if currentPeriod.rawValue != selectedPeriod.rawValue {
                pickerView.reloadComponent(Components.Values.rawValue)
            }
            currentPeriod = selectedPeriod
        }
        
        updateValueFromPicker(pickerView)
    }
    
    // MARK: - Private methods
    
    private func titleForPeriodInRow(row: Int) -> String {
        guard let period = Period(rawValue: row) else { return "" }
        return period.description()
    }
    
    private func titleForRow(row: Int, selectedPeriod: Period) -> String {
        switch selectedPeriod {
        case .Hours:
            if row < hours.count {
                return "\(hours[row])"
            }
        case .Minutes:
            if row < minutes.count {
                return "\(minutes[row])"
            }
        }
        
        return ""
    }
    
    private func selectedValueForRow(row: Int, period: Period) -> Int {
        switch period {
        case .Hours: return hours[row]
        case .Minutes: return minutes[row]
        }
    }
}