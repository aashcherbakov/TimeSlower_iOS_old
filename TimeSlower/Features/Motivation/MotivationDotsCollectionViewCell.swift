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
    fileprivate(set) var period: Period?
    
    func setupWithStats(_ stats: LifetimeStats, image: UIImage?, period: Period?, delegate: MotivationShareDelegate) {
        guard let period = period else { return }

        self.period = period
        let value = valueFromStats(stats, forPeriod: period)
        setupWithImage(image, value: value, period: period.description())
        
    }
    
    fileprivate func valueFromStats(_ stats: LifetimeStats, forPeriod period: Period) -> String {
        switch period {
        case .hours: return stats.hoursValueString()
        case .days: return stats.daysValueString()
        case .months: return stats.monthsValueString()
        case .years: return stats.yearsValueString()
            
        default:
            return ""
        }
    }
    
    fileprivate func setupWithImage(_ image: UIImage?, value: String, period: String) {
        valueLabel.text = value
        periodLabel.text = period.uppercased()
        imageView.image = image
    }
}
