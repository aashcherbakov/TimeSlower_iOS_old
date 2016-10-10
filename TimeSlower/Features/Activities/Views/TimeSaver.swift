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
    }

    // MARK: - Properties
    
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet var view: UIView!
    
    /// Selected time to save, Integer. Observable
    var selectedValue: MutableProperty<Endurance>?
    var selectedDuration: MutableProperty<Endurance>?
    
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

        selectedDuration?.producer.startWithResult { [weak self] (result) in
            guard let duration = result.value, let suggestedSaving = self?.minumumSavingForDuration(duration) else {
                return
            }
            
            self?.slider.minimumValue = duration.period == .hours ? Float(Constants.minimumMinutesToSave) : 1.0
            if self?.selectedValue == nil || Float(duration.value) != self?.slider.maximumValue {
                self?.selectedValue?.value = Endurance(value: suggestedSaving, period: duration.period)
            }
            
            self?.slider.maximumValue = Float(duration.value)
        }
        
        selectedValue?.producer.startWithResult { [weak self] (result) in
            guard let endurance = result.value, let duration = self?.selectedDuration?.value else { return }
            self?.timeLabel.text = "\(endurance.value) \(duration.period.description())"
            self?.slider.setValue(Float(endurance.value), animated: true)
        }
        
        slider.rac_signal(for: .valueChanged).toSignalProducer()
            .startWithResult { [weak self] (slider) in
                guard let slider = slider.value as? UISlider, let duration = self?.selectedDuration?.value else { return }
                self?.selectedValue?.value = Endurance(value: Int(slider.value), period: duration.period)
        }
    }
    
    fileprivate func minumumSavingForDuration(_ duration: Endurance) -> Int {
        var suggestedSaving = duration.value / 4
        if duration.period == .hours {
            suggestedSaving = suggestedSaving > Constants.minimumMinutesToSave ?
                suggestedSaving : Constants.minimumMinutesToSave
        }
        return suggestedSaving
    }
}
