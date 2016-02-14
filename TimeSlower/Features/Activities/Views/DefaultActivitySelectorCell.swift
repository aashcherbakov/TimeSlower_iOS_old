//
//  DefaultActivitySelectorCell.swift
//  TimeSlower2
//
//  Created by Oleksandr Shcherbakov on 8/4/15.
//  Copyright (c) 2015 1lastDay. All rights reserved.
//

import UIKit

class DefaultActivitySelectorCell: UICollectionViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var backgroundCircle: UIView!
    @IBOutlet weak var imageViewHeight: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let screenHeight = CGRectGetHeight(UIScreen.mainScreen().bounds)
        let imageHeightMultiplier: CGFloat = screenHeight > 568 ? 0.57 : 0.5
        imageViewHeight.constant = contentView.bounds.height * imageHeightMultiplier
        backgroundCircle.layer.cornerRadius = imageViewHeight.constant / 2
    }
    
}
