//
//  CircleProgress.swift
//  TimeSlower2
//
//  Created by Aleksander Shcherbakov on 7/14/15.
//  Copyright (c) 2015 1lastDay. All rights reserved.
//

import UIKit

class CircleProgress: UIView {

    struct Constants {
        static let animationDuration: CGFloat = 0.3
    }
    
    var progress = 0.0
    var progressBarWidth: CGFloat = 10.0
    var startAngle: CGFloat = 270
    var startProgress, endProgress, animationProgressStep: CGFloat!
    var currentAnimationProgress: CGFloat = 0.0
    var animationTimer: NSTimer!
    
    var progressColor = UIColor(red: 221/255, green: 75/255, blue: 77/255, alpha: 1)
    var trackColor: UIColor = UIColor(red: 240/255, green: 238/255, blue: 237/255, alpha: 1)

    func setProgress(progress: Double, animated: Bool) {
        setProgress(progress, animated: animated, duration: Constants.animationDuration)
    }

    
    private func setProgress(progress: Double, animated: Bool, duration: CGFloat) {
        self.progress = progressAccordingToBounds(progress)
        
        if animationTimer != nil {
            animationTimer.invalidate()
            animationTimer = nil
        }
        
        
        if animated {
            animateProgressBarChangeFrom(0.0, endProgress:CGFloat(progress), duration:Constants.animationDuration)
        } else {
            self.progress = progress
            setNeedsDisplay()
        }
    }
    
    func progressAccordingToBounds(var progress: Double) -> Double {
        progress = min(progress, 1)
        progress = max(progress, 0)
        return progress
    }
    
    
    func animateProgressBarChangeFrom(startProgress: CGFloat, endProgress: CGFloat, duration: CGFloat) {
        currentAnimationProgress = startProgress
        self.startProgress = startProgress
        self.endProgress = endProgress
        animationProgressStep = (endProgress - startProgress) * 0.01 / duration
        animationTimer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self,
            selector: Selector("updateProgressBarForAnimation"), userInfo: nil, repeats: true)
    }
    
    func updateProgressBarForAnimation() {
        currentAnimationProgress += animationProgressStep as CGFloat
        progress = Double(currentAnimationProgress)
        if (animationProgressStep > 0 && currentAnimationProgress >= endProgress)
            || (animationProgressStep < 0 && currentAnimationProgress <= endProgress) {
                
                animationTimer.invalidate()
                animationTimer = nil
                progress = Double(endProgress)
        }
        setNeedsDisplay()
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        backgroundColor = UIColor.clearColor()
        
        let innerCenter = CGPointMake(bounds.size.width / 2, bounds.size.height / 2)
        let radius = min(innerCenter.x, innerCenter.y)
        let currentAngleProgress = CGFloat(progress) * 360 + startAngle
        
        let context: CGContextRef = UIGraphicsGetCurrentContext()!
        CGContextClearRect(context, rect)
        
        drawBackground(context)
        drawProgressBar(context, progressAngle: currentAngleProgress, center: innerCenter, radius: radius)
    }
    
    func drawBackground(context: CGContextRef) {
        CGContextSetFillColorWithColor(context, UIColor.clearColor().CGColor)
        CGContextFillRect(context, bounds)
    }
    
    func drawProgressBar(context: CGContextRef, progressAngle: CGFloat, center: CGPoint, radius: CGFloat) {
                
        CGContextSetFillColorWithColor(context, progressColor.CGColor)
        CGContextBeginPath(context)
        CGContextAddArc(context, center.x, center.y, radius, startAngle.degreesToRadians, progressAngle.degreesToRadians, 0)
        CGContextAddArc(context, center.x, center.y, radius - progressBarWidth, progressAngle.degreesToRadians, startAngle.degreesToRadians, 1)
        CGContextClosePath(context)
        CGContextFillPath(context)
        
        CGContextSetFillColorWithColor(context, trackColor.CGColor)
        CGContextBeginPath(context)
        CGContextAddArc(context, center.x, center.y, radius, progressAngle.degreesToRadians, (startAngle + 360).degreesToRadians, 0)
        CGContextAddArc(context, center.x, center.y, radius - progressBarWidth, (startAngle + 360).degreesToRadians, progressAngle.degreesToRadians, 1)
        CGContextClosePath(context)
        CGContextFillPath(context)
    }
}



extension CGFloat {
    var degreesToRadians: CGFloat {
        return self * CGFloat(M_PI) / 180.0
    }
}