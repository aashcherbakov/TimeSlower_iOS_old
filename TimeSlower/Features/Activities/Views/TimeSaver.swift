//
//  TimeSaver.swift
//  TimeSlower2
//
//  Created by Aleksander Shcherbakov on 5/7/15.
//  Copyright (c) 2015 1lastDay. All rights reserved.
//

import UIKit
import ReactiveCocoa

/// UIView subclass that alows to select time to save for activity with UISlider
class TimeSaver: UIView {

    // MARK: - Properties
    
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet var view: UIView!
    
    /// Selected time to save, Integer. Observable
    dynamic var selectedValue: NSNumber?
    
    dynamic var selectedDuration: NSNumber?
    
    // MARK: - Overridden Methods
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupDesign()
        setupEvents()
    }
    
    // MARK: - Setup Methods
    
    private func setupDesign() {
        NSBundle.mainBundle().loadNibNamed("TimeSaver", owner: self, options: nil)
        bounds = view.bounds
        addSubview(view)
        
        let trackImage = UIImage(named: "redLine")
        UISlider.appearance().setMinimumTrackImage(trackImage, forState: .Normal)
        UISlider.appearance().setMaximumTrackImage(trackImage, forState: .Normal)
    }
    
    private func setupEvents() {
        slider.minimumValue = 1.0

        rac_valuesForKeyPath("selectedDuration", observer: self).toSignalProducer()
            .startWithNext { [weak self] (duration) in
                guard let duration = duration as? Float else { return }
                self?.slider.maximumValue = duration
                self?.selectedValue = duration / 6
                self?.slider.value = duration / 6
        }
        
        rac_valuesForKeyPath("selectedValue", observer: self).toSignalProducer()
            .startWithNext { [weak self] (value) in
                guard let value = value as? Int else { return }
                self?.timeLabel.text = "\(value) min"
        }
        
        slider.rac_signalForControlEvents(.ValueChanged).toSignalProducer()
            .startWithNext { [weak self] (slider) in
                guard let slider = slider as? UISlider else { return }
                self?.selectedValue = slider.value
        }
    }
}
