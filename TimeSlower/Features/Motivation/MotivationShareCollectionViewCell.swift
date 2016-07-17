//
//  MotivationShareCollectionViewCell.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 7/16/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import UIKit
import TimeSlowerKit

protocol MotivationShareDelegate {
    func motivationShareDelegateDidTapShareButton()
}

class MotivationShareCollectionViewCell: UICollectionViewCell, MotivationControlCell {

    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var middleLabel: UILabel!
    @IBOutlet weak var bottomLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    
    private var delegate: MotivationShareDelegate?

    @IBAction func shareButtonTapped(sender: AnyObject) {
        delegate?.motivationShareDelegateDidTapShareButton()
    }
    
    func setupWithStats(stats: LifetimeStats, image: UIImage?, period: Period?, delegate: MotivationShareDelegate) {
        self.delegate = delegate
        
        if stats.summYears.doubleValue > 1 {
            topLabel.text = stats.yearsDescription()
            middleLabel.text = stats.monthsDescription()
            bottomLabel.text = stats.daysDescription()
        } else {
            topLabel.text = stats.monthsDescription()
            middleLabel.text = stats.daysDescription()
            bottomLabel.text = stats.hoursDescription()
        }
        
        setupButton()
    }

    func setupButton() {
        shareButton.layer.cornerRadius = shareButton.frame.height / 2
    }
}
