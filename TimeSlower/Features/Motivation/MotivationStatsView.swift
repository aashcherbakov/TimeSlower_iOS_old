//
//  MotivationStatsView.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 7/11/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import UIKit

internal final class MotivationStatsView: UIView {

    @IBOutlet private(set) weak var view: UIView!
    @IBOutlet private(set) weak var startTimeTitleLabel: UILabel!
    @IBOutlet private(set) weak var durationTitleLabel: UILabel!
    @IBOutlet private(set) weak var startTimeLabel: UILabel!
    @IBOutlet private(set) weak var durationLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupXib()
    }
    
    func setupXib() {
        NSBundle.mainBundle().loadNibNamed(MotivationStatsView.className, owner: self, options: nil)
        bounds = view.bounds
        addSubview(view)
    }
    
    func setupWithStartTime(startTime: String, duration: String) {
        startTimeLabel.text = startTime
        durationLabel.text = duration
    }
}
