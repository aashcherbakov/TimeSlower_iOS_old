//
//  Motivator.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 10/23/15.
//  Copyright © 2015 Oleksandr Shcherbakov. All rights reserved.
//

import UIKit

public final class Motivator {
    
    static let circleHeightScale: CGFloat = 7
    
    enum RectSide {
        case Width
        case Height
    }
    
    
    class func imageWithDotsAmount(dots dots: Int, inFrame frame: CGRect) -> UIImage {
        var numDots = dots
        if dots > 2000 {
            numDots = 2000
        }
        
        let viewSize = frame.size
        let viewWidth = viewSize.width
        let viewHeight = viewSize.height
                
        let sideSizeAndName: (length: CGFloat, name: String) = Motivator.largestSideOfRect(height: viewHeight, width: viewWidth, numberOfRects: CGFloat(numDots))
        
        let sideA = sideSizeAndName.length
        let largestSideName = sideSizeAndName.name
        
        let numberOfSectionsSideA = (largestSideName == "width") ? viewWidth / sideA : viewHeight / sideA
        let numberOfSectionsSideB = ceil(CGFloat(numDots) / numberOfSectionsSideA)
        
        let sideB = (largestSideName == "width") ? viewHeight / numberOfSectionsSideB : viewWidth / numberOfSectionsSideB
        
        let shortestSideSections = min(numberOfSectionsSideA, numberOfSectionsSideB)
        let longestSideSections = max(numberOfSectionsSideA, numberOfSectionsSideB)
        
        let shortSide = min(sideA, sideB)
        let longSide = max(sideA, sideB)
        
        let optimalSize = CGSizeMake(shortSide * longestSideSections, shortSide * shortestSideSections)
        UIGraphicsBeginImageContext(optimalSize)
        let context = UIGraphicsGetCurrentContext()
        var totalCircles = 0
        
        for i in 0..<Int(shortestSideSections) {
            for j in 0..<Int(longestSideSections) {
                if totalCircles >= numDots {
                    break
                } else {
                    addCircle(longSide, shortSide: shortSide, longSection: j, shortSection: i, inContext: context, totalCircles: totalCircles)
                    
                    totalCircles += 1
                }
            }
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    
    public class func largestSideOfRect(height height: CGFloat, width: CGFloat, numberOfRects rectsTotal: CGFloat) -> (CGFloat, String) {
        
        var sx: CGFloat
        var sy: CGFloat
        
        let px = ceil(sqrt(rectsTotal * width / height))
        if (floor(px * height / width) * px) < rectsTotal {
            sx = height / ceil(px * height / rectsTotal)
        } else {
            sx = width / px
        }
        
        let py = ceil(sqrt(rectsTotal * height / width))
        if floor(py * width / height) * py < rectsTotal {
            sy = width / ceil(width * py / height)
        } else {
            sy = height / py
        }
        
        let maximum = max(sx, sy)
        let sideName = (maximum == sx) ? "width" : "height"
        return (maximum, sideName)
    }
    
    private class func addCircle(longSide: CGFloat, shortSide: CGFloat, longSection: Int, shortSection: Int,
                                 inContext context: CGContext?, totalCircles: Int) {
        
        let x = shortSide * CGFloat(longSection)
        let y = shortSide * CGFloat(shortSection)
        let width = shortSide
        let length = longSide
        let rect = CGRectMake(x, y, width, length)
        let newOriginX = rect.origin.x
        let smallerRect = CGRectMake(newOriginX, rect.origin.y, shortSide, shortSide)
        let inset = shortSide / 10
        let circleRect = CGRectInset(smallerRect, inset, inset)
        
        CGContextSetRGBFillColor(context, 255, 255, 255, 1)
        CGContextFillEllipseInRect(context, circleRect)
    }
    
}