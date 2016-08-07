//
//  PullNavigationAnimationController.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 8/6/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import UIKit

class PullNavigationAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    var presenting = false
    private var interactive = false
    private let screenHeight = UIScreen.mainScreen().bounds.height

    var transitionInProgress: Bool = false

    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.5
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let containterView = transitionContext.containerView()
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        
        let toView = toViewController.view
        let fromView = fromViewController.view
        
        if presenting {
            toView.transform = offStage(screenHeight)
        } else {
            toView.transform = offStage(-screenHeight)
        }
        
        containterView?.addSubview(toView)
        containterView?.addSubview(fromView)
        
        UIView.animateWithDuration(transitionDuration(transitionContext), animations: {
            if self.presenting {
                // if you don't want menu to be centered in screen, use offStage nethod
                // menuView.transform = self.offStage(-CGRectGetWidth(menuView.bounds) * 0.1)
                toView.transform = CGAffineTransformIdentity
                fromView.transform = self.offStage(-self.screenHeight)
            } else {
                toView.transform = CGAffineTransformIdentity
                fromView.transform = self.offStage(self.screenHeight)
            }
            
            }, completion: { finished in
                if transitionContext.transitionWasCancelled() {
                    fromView.userInteractionEnabled = true
                    toView.userInteractionEnabled = false
                    transitionContext.completeTransition(false)
                    UIApplication.sharedApplication().keyWindow?.addSubview(toView)
                } else {
                    fromView.userInteractionEnabled = false
                    toView.userInteractionEnabled = true
                    transitionContext.completeTransition(true)
                    UIApplication.sharedApplication().keyWindow?.addSubview(toView)
                }
        })
    }
    
    private func offStage(amount: CGFloat) -> CGAffineTransform {
        return CGAffineTransformMakeTranslation(0, amount)
    }
}