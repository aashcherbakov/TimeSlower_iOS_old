//
//  TimeSaver.swift
//  TimeSlower2
//
//  Created by Aleksander Shcherbakov on 5/7/15.
//  Copyright (c) 2015 1lastDay. All rights reserved.
//

import UIKit
import ReactiveSwift
import TimeSlowerKit

/// UIView subclass that alows to select time to save for activity with UISlider
class TimeSaver: UIView {
    
    fileprivate struct Constants {
        static let minimumMinutesToSave = 5
        static let minimumHoursToSave = 1
    }

    // MARK: - Properties
    
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet var view: UIView!
    
    /// Selected time to save, Integer. Observable
    var selectedValue = MutableProperty<Endurance?>(nil)
    var selectedDuration = MutableProperty<Endurance?>(nil)
    
    // MARK: - Overridden Methods
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupDesign()
        setupEvents()
    }
    
    // MARK: - Setup Methods
    
    fileprivate func setupDesign() {
        Bundle.main.loadNibNamed("TimeSaver", owner: self, options: nil)
        bounds = view.bounds
        addSubview(view)
        
        let trackImage = UIImage(named: "redLine")
        UISlider.appearance().setMinimumTrackImage(trackImage, for: UIControlState())
        UISlider.appearance().setMaximumTrackImage(trackImage, for: UIControlState())
    }
    
    fileprivate func setupEvents() {
        slider.minimumValue = 1.0
        
        subscribeToDurationChange()
        subscribeToSelectedValueChange()
        subscribeToSliderValueChange()
    }
    
    private func subscribeToDurationChange() {
        selectedDuration.producer.startWithValues { [weak self] (duration) in
            guard let duration = duration, let suggestedSaving = self?.minumumSavingForDuration(duration) else {
                return
            }
            
            self?.updateSliderBoundaries(withDuration: duration)
            self?.updateSlider(withValue: Float(suggestedSaving), period: duration.period)
            self?.resetSelectedValue(withDuration: duration, suggestedSaving: suggestedSaving)
        }
    }
    
    private func subscribeToSelectedValueChange() {
        selectedValue.producer.startWithResult { [weak self] (result) in
            guard let value = result.value, let sliderValue = value, let duration = self?.selectedDuration.value else {
                return
            }
            
            self?.updateSlider(withValue: Float(sliderValue.value), period: duration.period)
        }
    }
    
    private func subscribeToSliderValueChange() {
        slider.rac_signal(for: .valueChanged).toSignalProducer().startWithResult { [weak self] (slider) in
            guard let slider = slider.value as? UISlider, let duration = self?.selectedDuration.value else {
                return
            }
            
            self?.selectedValue.value = Endurance(value: Int(slider.value), period: duration.period)
        }
    }
    
    private func minumumSavingForDuration(_ duration: Endurance) -> Int {
        if let existingValue = selectedValue.value {
            return existingValue.minutes()
        }
        
        let suggestedSaving = duration.value / 4
        let minimum = minSaving(forPeriod: duration.period)
        
        if suggestedSaving < minimum {
            return minimum
        }
        
        return suggestedSaving
    }
    
    private func minSaving(forPeriod period: Period) -> Int {
        switch period {
        case .hours: return Constants.minimumHoursToSave
        case .minutes: return Constants.minimumMinutesToSave
        default: return 0
        }
    }
    
    private func resetSelectedValue(withDuration duration: Endurance, suggestedSaving: Int) {
        if selectedValue.value == nil || durationDidChange(duration) {
            selectedValue.value = Endurance(value: suggestedSaving, period: duration.period)
        }
    }
    
    private func durationDidChange(_ duration: Endurance) -> Bool {
        return Float(duration.value) != slider.maximumValue
    }
    
    private func updateSliderBoundaries(withDuration duration: Endurance) {
        slider.maximumValue = maxSliderValue(fromDuration: duration)
        slider.minimumValue = minSliderValue(fromDuration: duration)
    }
    
    private func minSliderValue(fromDuration duration: Endurance) -> Float {
        let value = duration.period == .hours ? 1 : Constants.minimumMinutesToSave
        return Float(value)
    }
    
    private func maxSliderValue(fromDuration duration: Endurance) -> Float {
        return Float(duration.value)
    }
    
    private func updateSlider(withValue value: Float, period: Period) {
        slider.setValue(value, animated: true)
        timeLabel.text = "\(Int(value)) \(period.description())"
    }

}
