//
//  MotivationIllustrator.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 7/23/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation

struct MotivationIllustrator {
    
    private struct Constants {
        static let dotsImageHeight: CGFloat = 20
        static let dotsImageWidth: CGFloat = 280
        static let firstColumnXScale: CGFloat = 0.16
        static let descriptionYScale: CGFloat = 0.3
    }
    
    let backgroundImage = UIImage(named: "share_pic_backgrounf")!
    let stats: LifetimeStats
    let descripton: String
    
    init(withStats stats: LifetimeStats, descriptionString: String) {
        self.stats = stats
        descripton = descriptionString
    }
    
    func createImageToShare() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(backgroundImage.size, false, UIScreen.mainScreen().scale)
        
        // Add background
        backgroundImage.drawInRect(CGRectMake(0, 0, backgroundImage.size.width, backgroundImage.size.height))
        
        let descriptionText = attributedDescription(descripton)
        descriptionText.drawInRect(frameForDescription(descriptionText))
        
        
        // Save and return
        let imageToShare = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return imageToShare
    }
    
    private func attributedDescription(description: String) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .Center
        let descriptionText = NSMutableAttributedString(string: descripton)
        descriptionText.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, descriptionText.length))
        let attributes = [NSParagraphStyleAttributeName  : paragraphStyle,
                          NSFontAttributeName            : UIFont.mainRegular(14),
                          NSForegroundColorAttributeName : UIColor.whiteColor()]
        
        descriptionText.addAttributes(attributes, range: NSMakeRange(0, descriptionText.length))
        return descriptionText
    }
    
    private func frameForDescription(description: NSAttributedString) -> CGRect {
        let preferedWidth = description.size().width / 2
        let preferedHeight = description.size().height * 3
        let descriptionX = backgroundImage.size.width / 2 - preferedWidth / 2
        let descriptionY = backgroundImage.size.height * Constants.descriptionYScale
        let descriptionFrame = CGRectMake(descriptionX, descriptionY, preferedWidth, preferedHeight)
        return descriptionFrame
    }
    
    private func labelsForStats(stats: LifetimeStats) -> [UILabel] {
        return [UILabel()]
    }
    
    private func imagesForStats(stats: LifetimeStats, originalFrame: CGRect) -> [UIImage] {
        return [UIImage()]
    }
    
    private func secondColumnX() -> CGFloat {
        return backgroundImage.size.width / 2
    }
    
    private func firstColumnx() -> CGFloat {
        return backgroundImage.size.width * Constants.firstColumnXScale
    }
}