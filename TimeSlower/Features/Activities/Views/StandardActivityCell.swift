//
//  StandardActivityCell.swift
//  TimeSlower2
//
//  Created by Aleksander Shcherbakov on 5/8/15.
//  Copyright (c) 2015 1lastDay. All rights reserved.
//

import UIKit
import TimeSlowerKit

class StandardActivityCell: UITableViewCell {


    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var factSavedTimeLabel: UILabel!
    @IBOutlet weak var plannedToSaveLabel: UILabel!
    @IBOutlet weak var savingsView: UIView!
    
    var activity: Activity! { didSet { setupLabels() } }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        savingsView.alpha = 0.0
    }

    func setupLabels() {
        nameLabel.text = activity.name.uppercased()
        startTimeLabel.text = dateFormatter.string(from: activity.updatedStartTime())
        if activity.isDoneForToday() {
            savingsView.alpha = 1.0
            let result = activity.stats.fastFactSavedForPeriod(.today)
            factSavedTimeLabel.text = "\(result)"
            plannedToSaveLabel.text = "\(activity.timing.timeToSave.int32Value)"
            
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()
    

}
