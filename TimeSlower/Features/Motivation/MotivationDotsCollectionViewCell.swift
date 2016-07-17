//
//  MotivationDotsCollectionViewCell.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 7/16/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import UIKit
import TimeSlowerKit

class MotivationDotsCollectionViewCell: UICollectionViewCell, MotivationControlCell {

    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var periodLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    private(set) var period: Period?
    
    func setupWithStats(stats: LifetimeStats, image: UIImage?, period: Period?, delegate: MotivationShareDelegate) {
        guard let period = period else { return }

        self.period = period
        let value = valueFromStats(stats, forPeriod: period)
        setupWithImage(image, value: value, period: period.description())
        
    }
    
    private func valueFromStats(stats: LifetimeStats, forPeriod period: Period) -> String {
        switch period {
        case .Hours: return stats.hoursValueString()
        case .Days: return stats.daysValueString()
        case .Months: return stats.monthsValueString()
        case .Years: return stats.yearsValueString()
            
        default:
            return ""
        }
    }
    
    private func setupWithImage(image: UIImage?, value: String, period: String) {
        valueLabel.text = value
        periodLabel.text = period.uppercaseString
        imageView.image = image
    }
}
