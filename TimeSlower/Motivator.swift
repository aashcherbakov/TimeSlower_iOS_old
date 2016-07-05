//
//  Motivator.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 10/23/15.
//  Copyright © 2015 Oleksandr Shcherbakov. All rights reserved.
//

import UIKit

class Motivator {
    
    static let circleHeightScale: CGFloat = 7
    
    private class func largestSideOfRect(height height: CGFloat, width: CGFloat, numberOfRects: Int) -> (CGFloat, String) {
        
        let x = width, y = height, n = CGFloat(numberOfRects)
        var sx: CGFloat, sy: CGFloat
        
        let px = ceil(sqrt(n * x / y))
        if (floor(px * y / x) * px) < n {
            sx = y / ceil(px * y / n)
        } else {
            sx = x / px
        }
        
        let py = ceil(sqrt(n * y / x))
        if floor(py * x / y) * py < n {
            sy = x / ceil(x * py / y)
        } else {
            sy = y / py
        }
        let maximum = max(sx, sy)
        let sideName = (maximum == sx) ? "width" : "height"
        return (maximum, sideName)
    }
    
    
    class func imageWithDotsAmount(dots dots: Int, inFrame frame: CGRect) -> UIImage {
        let viewSize = frame.size
        let viewWidth = CGFloat(viewSize.width)
        let viewHeight = CGFloat(viewSize.height)
        
        UIGraphicsBeginImageContext(viewSize)
        
        let sideSizeAndName: (CGFloat, String) = Motivator.largestSideOfRect(height: viewHeight, width: viewWidth, numberOfRects: dots)
        let sideA = sideSizeAndName.0
        let name = sideSizeAndName.1
        
        let numberOfSectionsSideA = (name == "width") ? viewWidth / sideA : viewHeight / sideA
        let numberOfSectionsSideB = ceil(CGFloat(dots) / numberOfSectionsSideA)
        
        let sideB = (name == "width") ? viewHeight / numberOfSectionsSideB : viewWidth / numberOfSectionsSideB
        
        let shortestSideSections = min(numberOfSectionsSideA, numberOfSectionsSideB)
        let longestSideSections = max(numberOfSectionsSideA, numberOfSectionsSideB)
        
        let shortSide = min(sideA, sideB)
        let longSide = max(sideA, sideB)
        
        let context = UIGraphicsGetCurrentContext()
        var totalCircles = 0
        
        for i in 0..<Int(longestSideSections) {
            for j in 0..<Int(shortestSideSections) {
                if totalCircles >= dots {
                    break
                } else {
                    let rect = CGRectMake(longSide * CGFloat(i), shortSide * CGFloat(j), longSide, shortSide)
                    let newOriginX = rect.origin.x + (longSide - shortSide) / 2
                    let smallerRect = CGRectMake(newOriginX, rect.origin.y, shortSide, shortSide)
                    let inset = shortSide / 10
                    let circleRect = CGRectInset(smallerRect, inset, inset)
                    CGContextSetRGBFillColor(context, 255, 255, 255, 1)
                    CGContextFillEllipseInRect(context, circleRect)
                    
                    totalCircles += 1
                }
            }
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
}