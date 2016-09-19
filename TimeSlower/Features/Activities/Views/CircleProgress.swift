//
//  CircleProgress.swift
//  TimeSlower2
//
//  Created by Aleksander Shcherbakov on 7/14/15.
//  Copyright (c) 2015 1lastDay. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}

fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}


class CircleProgress: UIView {

    struct Constants {
        static let animationDuration: CGFloat = 0.3
    }
    
    var progress = 0.0
    var progressBarWidth: CGFloat = 10.0
    var startAngle: CGFloat = 270
    var startProgress, endProgress, animationProgressStep: CGFloat!
    var currentAnimationProgress: CGFloat = 0.0
    var animationTimer: Foundation.Timer!
    
    var progressColor = UIColor(red: 221/255, green: 75/255, blue: 77/255, alpha: 1)
    var trackColor: UIColor = UIColor(red: 240/255, green: 238/255, blue: 237/255, alpha: 1)

    func setProgress(_ progress: Double, animated: Bool) {
        setProgress(progress, animated: animated, duration: Constants.animationDuration)
    }

    
    fileprivate func setProgress(_ progress: Double, animated: Bool, duration: CGFloat) {
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
    
    func progressAccordingToBounds(_ progress: Double) -> Double {
        var mutableProgress = progress
        mutableProgress = min(progress, 1)
        mutableProgress = max(progress, 0)
        return mutableProgress
    }
    
    
    func animateProgressBarChangeFrom(_ startProgress: CGFloat, endProgress: CGFloat, duration: CGFloat) {
        currentAnimationProgress = startProgress
        self.startProgress = startProgress
        self.endProgress = endProgress
        animationProgressStep = (endProgress - startProgress) * 0.01 / duration
        animationTimer = Foundation.Timer.scheduledTimer(timeInterval: 0.01, target: self,
            selector: #selector(CircleProgress.updateProgressBarForAnimation), userInfo: nil, repeats: true)
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
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        backgroundColor = UIColor.clear
        
        let innerCenter = CGPoint(x: bounds.size.width / 2, y: bounds.size.height / 2)
        let radius = min(innerCenter.x, innerCenter.y)
        let currentAngleProgress = CGFloat(progress) * 360 + startAngle
        
        let context: CGContext = UIGraphicsGetCurrentContext()!
        context.clear(rect)
        
        drawBackground(context)
        drawProgressBar(context, progressAngle: currentAngleProgress, center: innerCenter, radius: radius)
    }
    
    func drawBackground(_ context: CGContext) {
        context.setFillColor(UIColor.clear.cgColor)
        context.fill(bounds)
    }
    
    func drawProgressBar(_ context: CGContext, progressAngle: CGFloat, center: CGPoint, radius: CGFloat) {
                
        context.setFillColor(progressColor.cgColor)
        context.beginPath()
        context.addArc(center: center, radius: startAngle.degreesToRadians, startAngle: progressAngle.degreesToRadians, endAngle: 0, clockwise: true)
        context.addArc(center: center, radius: radius - progressBarWidth, startAngle: progressAngle.degreesToRadians, endAngle: startAngle.degreesToRadians, clockwise: true)
        context.closePath()
        context.fillPath()
        
        context.setFillColor(trackColor.cgColor)
        context.beginPath()
//        CGContextAddArc(context, center.x, center.y, radius, progressAngle.degreesToRadians, (startAngle + 360).degreesToRadians, 0)
//        CGContextAddArc(context, center.x, center.y, radius - progressBarWidth, (startAngle + 360).degreesToRadians, progressAngle.degreesToRadians, 1)
        context.closePath()
        context.fillPath()
    }
}



extension CGFloat {
    var degreesToRadians: CGFloat {
        return self * CGFloat(M_PI) / 180.0
    }
}
