//
//  TimeSaver.swift
//  TimeSlower2
//
//  Created by Aleksander Shcherbakov on 5/7/15.
//  Copyright (c) 2015 1lastDay. All rights reserved.
//

import UIKit
import RxSwift

/// UIView subclass that alows to select time to save for activity with UISlider
class TimeSaver: UIView {

    // MARK: - Properties
    
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet var view: UIView!
    
    /// Selected time to save, Double. Observable
    var timeToSave = Variable<Int>(0)
    
    /// Duration selected by user
    var activityDuration = Variable<Int>(30)

    private let disposableBag = DisposeBag()
    
    // MARK: - Overridden Methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
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

        activityDuration
            .subscribeNext { [weak self] (duration) -> Void in
                self?.slider.maximumValue = Float(duration)
                self?.timeToSave.value = duration / 6
                self?.slider.value = Float(duration / 6)
            }
            .addDisposableTo(disposableBag)
        
        timeToSave
            .subscribeNext { [weak self] (minutes) -> Void in
                self?.timeLabel.text = "\(minutes) min"
            }
            .addDisposableTo(disposableBag)
        
        slider.rx_value
            .subscribeNext { [weak self] (minutes) -> Void in
                self?.timeToSave.value = Int(minutes)
            }
            .addDisposableTo(disposableBag)
    }
}
