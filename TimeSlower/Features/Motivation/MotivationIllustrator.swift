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
        static let dotsImageHeight: CGFloat = 30
        static let dotsImageWidth: CGFloat = 160
        static let firstColumnXScale: CGFloat = 0.16
        static let secondColumnXScale: CGFloat = 0.5
        static let descriptionYScale: CGFloat = 0.3
        static let firstLineYScale: CGFloat = 0.5
        static let lineYOffsetScale: CGFloat = 0.12
        
    }
    
    let backgroundImage = UIImage(named: "share_pic_backgrounf")!
    let stats: LifetimeStats
    let descripton: NSAttributedString
    
    init(withStats stats: LifetimeStats, descriptionString: NSAttributedString) {
        self.stats = stats
        descripton = descriptionString
    }
    
    func createImageToShare() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(backgroundImage.size, false, 0)
        
        // Add background
        backgroundImage.drawInRect(CGRectMake(0, 0, backgroundImage.size.width, backgroundImage.size.height))
        
        // Add description
        descripton.drawInRect(frameForDescription(descripton))
        
        let offset = backgroundImage.size.height * Constants.lineYOffsetScale

        // Add strings
        let labels = labelsForStats(stats)
        for label in labels {
            let index = labels.indexOf(label)!
            let labelX = backgroundImage.size.width * Constants.firstColumnXScale
            let labelY = backgroundImage.size.height * Constants.firstLineYScale + CGFloat(index) * offset
            label.drawInRect(CGRectMake(labelX, labelY, label.size().width, label.size().height))
        }
        
        // Add dots
        let frame = CGRectMake(0, 0, Constants.dotsImageWidth, Constants.dotsImageHeight)
        let images = imagesForStats(stats, originalFrame: frame)
        for image in images {
            let index = images.indexOf(image)!
            let imageX = backgroundImage.size.width * Constants.secondColumnXScale
            let imageY = backgroundImage.size.height * Constants.firstLineYScale + CGFloat(index) * offset
            image.drawInRect(CGRectMake(imageX, imageY, image.size.width, image.size.height))
        }
        
        // Save and return
        let imageToShare = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return imageToShare
    }
    
    private func frameForDescription(description: NSAttributedString) -> CGRect {
        let preferedWidth = description.size().width * 0.7
        let preferedHeight = description.size().height * 2
        let descriptionX = backgroundImage.size.width / 2 - preferedWidth / 2
        let descriptionY = backgroundImage.size.height * Constants.descriptionYScale
        let descriptionFrame = CGRectMake(descriptionX, descriptionY, preferedWidth, preferedHeight)
        return descriptionFrame
    }
    
    private func labelsForStats(stats: LifetimeStats) -> [NSAttributedString] {
        var strings = [NSAttributedString]()
        
        strings.append(stats.monthsAttributedDescription())
        strings.append(stats.daysAttributedDescription())
        
        if stats.summYears.integerValue >= 1 {
            strings.insert(stats.yearsAttributedDescription(), atIndex: 0)
        } else {
            strings.append(stats.hoursAttributedDescription())
        }
        
        return strings
    }
    
    private func imagesForStats(stats: LifetimeStats, originalFrame: CGRect) -> [UIImage] {
        var images = [UIImage]()
        
        images.append(Motivator.imageWithDotsAmount(dots: stats.summMonth.integerValue, inFrame: originalFrame))
        images.append(Motivator.imageWithDotsAmount(dots: stats.summDays.integerValue, inFrame: originalFrame))
        
        if stats.summYears.integerValue >= 1 {
            images.insert(Motivator.imageWithDotsAmount(dots: stats.summYears.integerValue, inFrame: originalFrame), atIndex: 0)
        } else {
            images.append(Motivator.imageWithDotsAmount(dots: stats.summHours.integerValue, inFrame: originalFrame))
        }
        
        return images
    }
    
    private func secondColumnX() -> CGFloat {
        return backgroundImage.size.width / 2
    }
    
    private func firstColumnx() -> CGFloat {
        return backgroundImage.size.width * Constants.firstColumnXScale
    }
}