//
//  Motivator.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 10/23/15.
//  Copyright © 2015 Oleksandr Shcherbakov. All rights reserved.
//

import UIKit

/// DO NOT MODIFY ANY OF THIS - BLACK MAGIC WORKING - ¯\_(ツ)_/¯
public final class Motivator {
    
    static let circleHeightScale: CGFloat = 7
    
    class func imageWithDotsAmount(_ dots: Int, inFrame frame: CGRect) -> UIImage {
        var numDots = dots
        
        // We often have more than 2000 dots but it's expensive to draw and no one can see tiny dots
        if dots > 2000 {
            numDots = 2000
        }
        
        let viewSize = frame.size
        let viewWidth = viewSize.width
        let viewHeight = viewSize.height
                
        let sideSizeAndName: (length: CGFloat, name: String) = Motivator.largestSideOfRect(viewHeight, width: viewWidth, numberOfRects: CGFloat(numDots))
        
        let sideA = sideSizeAndName.length
        let largestSideName = sideSizeAndName.name
        
        let numberOfSectionsSideA = (largestSideName == "width") ? ceil(viewWidth / sideA) : ceil(viewHeight / sideA)
        let numberOfSectionsSideB = ceil(CGFloat(numDots) / numberOfSectionsSideA)
        
        let sideB = (largestSideName == "width") ? viewHeight / numberOfSectionsSideB : viewWidth / numberOfSectionsSideB
        
        let shortestSideSections = min(numberOfSectionsSideA, numberOfSectionsSideB)
        let longestSideSections = max(numberOfSectionsSideA, numberOfSectionsSideB)
        
        let shortSide = min(sideA, sideB)
        let longSide = max(sideA, sideB)
        
        // Optimal size of image is needed to center image layout. If there is one dot, optimal size is a dot frame.
        var optimalSize = CGSize(width: shortSide * longestSideSections, height: shortSide * shortestSideSections)
        if dots == 1 {
            optimalSize = CGSize(width: shortSide, height: shortSide)
        }
        
        UIGraphicsBeginImageContextWithOptions(optimalSize, false, UIScreen.main.scale)
        let context = UIGraphicsGetCurrentContext()
        
        // Draw circles here
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
        return image!
    }
    
    // Black Magic
    public class func largestSideOfRect(_ height: CGFloat, width: CGFloat, numberOfRects rectsTotal: CGFloat) -> (CGFloat, String) {
        var sx: CGFloat
        var sy: CGFloat
        
        let px = ceil(sqrt(rectsTotal * width / height))
        if (floor(px * height / width) * px) < rectsTotal {
            sx = height / ceil(px * height / width)
        } else {
            sx = width / px
        }
        
        let py = ceil(sqrt(rectsTotal * height / width))
        if (floor(py * width / height) * py) < rectsTotal {
            sy = width / ceil(py * width / height)
        } else {
            sy = height / py
        }
        
        let maximum = max(sx, sy)
        let sideName = (maximum == sx) ? "width" : "height"
        return (maximum, sideName)
    }
    
    // Simple drawing method
    fileprivate class func addCircle(_ longSide: CGFloat, shortSide: CGFloat, longSection: Int, shortSection: Int,
                                 inContext context: CGContext?, totalCircles: Int) {
        
        let x = shortSide * CGFloat(longSection)
        let y = shortSide * CGFloat(shortSection)
        let width = shortSide
        let length = longSide
        let rect = CGRect(x: x, y: y, width: width, height: length)
        let newOriginX = rect.origin.x
        let smallerRect = CGRect(x: newOriginX, y: rect.origin.y, width: shortSide, height: shortSide)
        let inset = shortSide / 10
        let circleRect = smallerRect.insetBy(dx: inset, dy: inset)
        
        context?.setFillColor(red: 255, green: 255, blue: 255, alpha: 1)
        context?.fillEllipse(in: circleRect)
    }
    
}
