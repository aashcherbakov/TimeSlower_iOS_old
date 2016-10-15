//
//  MotivationIllustrator.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 7/23/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation

struct MotivationIllustrator {
    
    fileprivate struct Constants {
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
        backgroundImage.draw(in: CGRect(x: 0, y: 0, width: backgroundImage.size.width, height: backgroundImage.size.height))
        
        // Add description
        descripton.draw(in: frameForDescription(descripton))
        
        let offset = backgroundImage.size.height * Constants.lineYOffsetScale

        // Add strings
        let labels = labelsForStats(stats)
        for label in labels {
            let index = labels.index(of: label)!
            let labelX = backgroundImage.size.width * Constants.firstColumnXScale
            let labelY = backgroundImage.size.height * Constants.firstLineYScale + CGFloat(index) * offset
            label.draw(in: CGRect(x: labelX, y: labelY, width: label.size().width, height: label.size().height))
        }
        
        // Add dots
        let frame = CGRect(x: 0, y: 0, width: Constants.dotsImageWidth, height: Constants.dotsImageHeight)
        let images = imagesForStats(stats, originalFrame: frame)
        for image in images {
            let index = images.index(of: image)!
            let imageX = backgroundImage.size.width * Constants.secondColumnXScale
            let imageY = backgroundImage.size.height * Constants.firstLineYScale + CGFloat(index) * offset
            image.draw(in: CGRect(x: imageX, y: imageY, width: image.size.width, height: image.size.height))
        }
        
        // Save and return
        let imageToShare = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return imageToShare!
    }
    
    fileprivate func frameForDescription(_ description: NSAttributedString) -> CGRect {
        let preferedWidth = description.size().width * 0.7
        let preferedHeight = description.size().height * 2
        let descriptionX = backgroundImage.size.width / 2 - preferedWidth / 2
        let descriptionY = backgroundImage.size.height * Constants.descriptionYScale
        let descriptionFrame = CGRect(x: descriptionX, y: descriptionY, width: preferedWidth, height: preferedHeight)
        return descriptionFrame
    }
    
    fileprivate func labelsForStats(_ stats: LifetimeStats) -> [NSAttributedString] {
        var strings = [NSAttributedString]()
        
        strings.append(stats.monthsAttributedDescription())
        strings.append(stats.daysAttributedDescription())
        
        if stats.summYears.int32Value >= 1 {
            strings.insert(stats.yearsAttributedDescription(), at: 0)
        } else {
            strings.append(stats.hoursAttributedDescription())
        }
        
        return strings
    }
    
    fileprivate func imagesForStats(_ stats: LifetimeStats, originalFrame: CGRect) -> [UIImage] {
        var images = [UIImage]()
        
        images.append(Motivator.imageWithDotsAmount(stats.summMonth.intValue, inFrame: originalFrame))
        images.append(Motivator.imageWithDotsAmount(stats.summDays.intValue, inFrame: originalFrame))
        
        if stats.summYears.int32Value >= 1 {
            images.insert(Motivator.imageWithDotsAmount(stats.summYears.intValue, inFrame: originalFrame), at: 0)
        } else {
            images.append(Motivator.imageWithDotsAmount(stats.summHours.intValue, inFrame: originalFrame))
        }
        
        return images
    }
    
    fileprivate func secondColumnX() -> CGFloat {
        return backgroundImage.size.width / 2
    }
    
    fileprivate func firstColumnx() -> CGFloat {
        return backgroundImage.size.width * Constants.firstColumnXScale
    }
}
