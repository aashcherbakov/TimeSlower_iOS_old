//
//  EditActivityDurationView.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 2/21/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import UIKit
import ReactiveSwift
import TimeSlowerKit

/// UITableViewCell subclass to edit duration of activity
class EditActivityDurationView: ObservableControl {
    
    /**
     Components of UIPickerView
     
     - Values:  represents numbers
     - Periods: represents time measurements: minutes or hours
     */
    enum Components: Int {
        case values
        case periods
    }
    
    fileprivate struct Constants {
        static let defaultDuration = 30
    }
    
    // MARK: - Properties
    
    /// Duration of activity in minutes. Observable.
    var selectedValue: MutableProperty<Endurance>?
    
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var textfieldView: TextfieldView!
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var separatorLineHeight: NSLayoutConstraint!
    
    fileprivate let minutes = [5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55]
    fileprivate let hours = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    fileprivate var currentPeriod: Period = .minutes

    fileprivate var valueChangedSignal: SignalProducer<Any?, NSError>?

    // MARK: - Overriden Methods
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupXib()
        
        setupEvents()
        setupDesign()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)

        sendActions(for: .touchUpInside)
        updateValueFromPicker(pickerView)
    }
    
    override func valueSignal() -> SignalProducer<Any?, NSError>? {
        return valueChangedSignal
    }
    
    override func setInitialValue(_ value: AnyObject?) {
        if let duration = value as? Endurance {
            selectedValue?.value = duration
            textfieldView.setText("Duration: \(duration.value) \(duration.period.description())")
            setPickerViewToValue(duration.value, period: duration.period)
        }
    }
    
    // MARK: - Private Methods
    
    fileprivate func setupXib() {
        Bundle.main.loadNibNamed(EditActivityDurationView.className, owner: self, options: nil)
        bounds = view.bounds
        addSubview(view)
    }
    
    fileprivate func setupDesign() {
        textfieldView.setupWithConfig(DurationTextfield())
        separatorLineHeight.constant = kDefaultSeparatorHeight
        pickerView.selectRow(4, inComponent: Components.values.rawValue, animated: false)
    }
    
    fileprivate func setupEvents() {
        pickerView.delegate = self
        pickerView.dataSource = self
        
        valueChangedSignal = rac_values(forKeyPath: "selectedValue", observer: self).toSignalProducer()
    }
    
    fileprivate func setPickerViewToValue(_ value: Int, period: Period) {
        let valuesArray = period == .minutes ? minutes : hours
        if let row = valuesArray.index(of: value) {
            pickerView.selectRow(row, inComponent: period.rawValue, animated: false)
        }
    }
    
    fileprivate func updateValueFromPicker(_ pickerView: UIPickerView) {
        let values = getValuesFromPickerView(pickerView)
        if selectedValue?.value.value != values.value {
            self.updateSelectedValueWithDuration(values.value, period: values.period)
        }
    }
    
    fileprivate func getValuesFromPickerView(_ pickerView: UIPickerView) -> (value: Int, period: Period) {
        let row = pickerView.selectedRow(inComponent: Components.values.rawValue)
        if let
            period = Period(rawValue: pickerView.selectedRow(inComponent: Components.periods.rawValue)),
            let value = selectedValueForRow(row, period: period) {
            return (value, period)
        } else {
            fatalError("DatePicker has only one component")
        }
    }
    
    fileprivate func updateSelectedValueWithDuration(_ duration: Int, period: Period) {
        selectedValue?.value = Endurance(value: duration, period: period)
        textfieldView.setText("Duration: \(duration) \(period.description())")
    }
}

// MARK: - UIPickerViewDataSource
extension EditActivityDurationView: UIPickerViewDataSource {
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard let selectedComponent = Components(rawValue: component) else { return 0 }
        
        switch selectedComponent {
        case .values: return currentPeriod == .hours ? hours.count : minutes.count
        case .periods: return 2
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
}

// MARK: - UIPickerViewDelegate
extension EditActivityDurationView: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let selectedComponent = Components(rawValue: component) else { return nil }
        
        switch selectedComponent {
        case .values: return titleForRow(row, selectedPeriod: currentPeriod)
        case .periods: return titleForPeriodInRow(row)
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let selectedComponent = Components(rawValue: component) else { return }
       
        if let selectedPeriod = Period(rawValue: row) , selectedComponent == .periods {
            if currentPeriod.rawValue != selectedPeriod.rawValue {
                pickerView.reloadComponent(Components.values.rawValue)
            }
            currentPeriod = selectedPeriod
        }
        
        updateValueFromPicker(pickerView)
    }
    
    // MARK: - Private methods
    
    fileprivate func titleForPeriodInRow(_ row: Int) -> String {
        guard let period = Period(rawValue: row) else { return "" }
        return period.description()
    }
    
    fileprivate func titleForRow(_ row: Int, selectedPeriod: Period) -> String {
        switch selectedPeriod {
        case .hours:
            if row < hours.count {
                return "\(hours[row])"
            }
        case .minutes:
            if row < minutes.count {
                return "\(minutes[row])"
            }
        default: return ""
        }
        
        return ""
    }
    
    fileprivate func selectedValueForRow(_ row: Int, period: Period) -> Int? {
        switch period {
        case .hours:
            return row < hours.count ? hours[row] : hours.last
        case .minutes:
            return row < minutes.count ? minutes[row] : minutes.last
        default: return nil
        }
    }
}
