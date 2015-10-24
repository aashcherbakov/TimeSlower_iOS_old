//
//  TimeSaver.swift
//  TimeSlower2
//
//  Created by Aleksander Shcherbakov on 5/7/15.
//  Copyright (c) 2015 1lastDay. All rights reserved.
//

import UIKit
import TimeSlowerKit

class TimeSaver: UIView {

    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet var view: UIView!
    
    var activity: Activity? {
        didSet {
            duration = activity!.timing.duration.doubleValue
        }
    }
    var selectedDuration: Double!
    var selectedTimeToSave: Double!
    var duration: Double!
    var sliderValue: Double!
    private let format = ".0"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupValues()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupXib()
    }
    
    func setupXib() {
        NSBundle.mainBundle().loadNibNamed("TimeSaver", owner: self, options: nil)
        bounds = view.bounds
        addSubview(view)
    }

    func setupValues() {
        if activity != nil {
            setupActivityValues()
        } else {
            setupDefaultValues()
        }
    }
    
    func setupActivityValues() {
        
    }
    
    func setupDefaultValues() {
        slider.maximumValue = 30.0
        slider.minimumValue = 1.0
        slider.value = 5.0
        timeLabel.text = "\(slider.value.format(format)) min"
    }
    
    
    @IBAction func sliderSlided(sender: UISlider) {
        timeLabel.text = "\(sender.value.format(format)) min"
    }
}

extension Float {
    func format(f: String) -> String {
        return NSString(format: "%\(f)f", self) as String
    }
}

extension Double {
    func format(f: String) -> String {
        return NSString(format: "%\(f)f", self) as String
    }
}
