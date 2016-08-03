//
//  ActivityListTransitionManager.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 7/31/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation

class ActivityListTransitionManager: UIPercentDrivenInteractiveTransition {
    
    private enum TransitionDirection {
        case Onstage
        case Offstage
    }
    
    var sourceController: UIViewController? { didSet { setupEnterGesture() } }
    var activityListController: UIViewController? { didSet { setupExitGesture() } }
    
    private var presenting = false
    private var interactive = false
    private var enterGesture: UIPanGestureRecognizer?
    private var exitGesture: UIPanGestureRecognizer?
    
    private let screenHeight = UIScreen.mainScreen().bounds.height
    
    func handleOnstagePan(pan: UIPanGestureRecognizer) {
        handleTransitionInDirection(.Onstage, recognizer: pan)
    }
    
    func handleOffstagePan(pan: UIPanGestureRecognizer) {
        handleTransitionInDirection(.Offstage, recognizer: pan)
    }
    
    private func setupEnterGesture() {
        let enterGesture = UIPanGestureRecognizer()
        enterGesture.addTarget(self, action: #selector(ActivityListTransitionManager.handleOnstagePan(_:)))
        sourceController?.view.addGestureRecognizer(enterGesture)
    }
    
    private func setupExitGesture() {
        let exitGesture = UIPanGestureRecognizer()
        exitGesture.addTarget(self, action: #selector(ActivityListTransitionManager.handleOffstagePan(_:)))
        activityListController?.view.addGestureRecognizer(exitGesture)
    }
    
    private func handleTransitionInDirection(direction: TransitionDirection, recognizer: UIPanGestureRecognizer) {
        
        let progress = progressForPanGesture(inRecognizer: recognizer, direction: direction)
        guard progress > 0 else {
            if recognizer.state == .Ended {
                interactive = false
                cancelInteractiveTransition()
            }
            return
        }
        
        handleRecognizerState(recognizer.state, withProgress: progress, direction: direction)
    }
    
    private func progressForPanGesture(inRecognizer recognizer: UIPanGestureRecognizer, direction: TransitionDirection) -> CGFloat {
        
        guard let view = recognizer.view else { return 0 }
        let screenTranslationAdjustment: CGFloat = direction == .Onstage ? 0.5 : -0.5
        let translation = recognizer.translationInView(view)
        return -translation.y / CGRectGetHeight(view.bounds) * screenTranslationAdjustment
    }
    
    private func handleRecognizerState(state: UIGestureRecognizerState, withProgress
        progress: CGFloat, direction: TransitionDirection) {
        switch state {
        case .Began:
            interactive = true
            presentController(forDirection: direction)
            
        case .Changed:
            updateInteractiveTransition(progress)
            
        default: // .Canceled, .Ended etc.
            interactive = false
            finishTransition(withProgress: progress, direction: direction)
        }
    }
    
    private func presentController(forDirection direction: TransitionDirection) {
        if direction == .Onstage {
            guard let currentVC = sourceController as? HomeViewController else {
                return
            }
            
            let listController: ListOfActivitiesVC = ControllerFactory.createController()
            listController.profile = currentVC.profile
            listController.transitioningDelegate = currentVC.activityListTransitionManager
            activityListController = listController
            sourceController?.presentViewController(listController, animated: true, completion: nil)
        } else {
            activityListController?.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    private func finishTransition(withProgress progress: CGFloat, direction: TransitionDirection) {
        let minTransition: CGFloat = direction == .Onstage ? 0.1 : 0.1
        print(progress)
        if progress > minTransition {
            finishInteractiveTransition()
        } else {
            cancelInteractiveTransition()
        }
    }
}

extension ActivityListTransitionManager: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.5
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        guard let
            container = transitionContext.containerView(),
            controllers = controllersFromContext(transitionContext)
            else {
                return
        }
        
        let menuController = !presenting ? controllers.top : controllers.destination
        let topController = !presenting ? controllers.destination : controllers.top
        topController.view.layer.shadowOpacity = 0.8
        
        let menuView = menuController.view
        let topView = topController.view
        
        if presenting {
            menuView.transform = offStage(screenHeight)
        }
        
        container.addSubview(menuView)
        container.addSubview(topView)
        
        // This variable has to be initialized before calling animateInteractiveTransition
        let duration = transitionDuration(transitionContext)
        
        animateIntractiveTransition(
            inContext: transitionContext,
            duration: duration,
            menuView: menuView,
            topView: topView,
            isPresenting: presenting)
    }
    
    private func animateIntractiveTransition(
        inContext transitionContext: UIViewControllerContextTransitioning,
                  duration: NSTimeInterval,
                  menuView: UIView,
                  topView: UIView,
                  isPresenting: Bool) {
        
        UIView.animateWithDuration(duration, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.2, options: [],
                                   animations: { [weak self] in
                                    self?.performViewTransformations(ifPresenting: isPresenting, menuView: menuView, topView: topView)
            }, completion: { [weak self] finished in
                self?.completeInteractiveTransition(inContext: transitionContext, isPresenting: isPresenting)
            })
    }
    
    // MARK: - Transformation Helpers
    
    private func performViewTransformations(ifPresenting presenting: Bool, menuView: UIView, topView: UIView) {
        if presenting {
            // if you don't want menu to be centered in screen, use offStage nethod
            // menuView.transform = self.offStage(-CGRectGetWidth(menuView.bounds) * 0.1)
            menuView.transform = CGAffineTransformIdentity
            topView.transform = self.offStage(-screenHeight)
        } else {
            topView.transform = CGAffineTransformIdentity
            menuView.transform = self.offStage(screenHeight)
        }
    }
    
    private func offStage(amount: CGFloat) -> CGAffineTransform {
        return CGAffineTransformMakeTranslation(0, amount)
    }
    
    
    // MARK: - Transition Context manipulations
    
    private func completeInteractiveTransition(inContext transitionContext: UIViewControllerContextTransitioning, isPresenting: Bool) {
        guard let controllers = self.controllersFromContext(transitionContext) else { return }
        
        if transitionContext.transitionWasCancelled() {
            controllers.top.view.userInteractionEnabled = true
            controllers.destination.view.userInteractionEnabled = false
            transitionContext.completeTransition(false)
            UIApplication.sharedApplication().keyWindow?.addSubview(controllers.top.view)
        } else {
            controllers.top.view.userInteractionEnabled = false
            controllers.destination.view.userInteractionEnabled = true
            transitionContext.completeTransition(true)
            UIApplication.sharedApplication().keyWindow?.addSubview(controllers.destination.view)
        }
        
//        // fix for bug when second view dissapears from screen
//        // http://openradar.appspot.com/radar?id=5320103646199808
//        if isPresenting {
//            UIApplication.sharedApplication().keyWindow?.addSubview(controllers.top.view)
//        } else {
//            UIApplication.sharedApplication().keyWindow?.addSubview(controllers.destination.view)
//        }
    }
    
    private func controllersFromContext(transitionContext: UIViewControllerContextTransitioning) ->
        (top: UIViewController, destination: UIViewController)? {
            
            guard let
                topController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey),
                destinationController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
                else {
                    return nil
            }
            return (topController, destinationController)
    }
}

extension ActivityListTransitionManager: UIViewControllerTransitioningDelegate {
    
    func animationControllerForPresentedController(
        presented: UIViewController,
        presentingController presenting: UIViewController,
                             sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.presenting = true
        return self
    }
    
    func animationControllerForDismissedController(
        dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.presenting = false
        return self
    }
    
    func interactionControllerForPresentation(animator: UIViewControllerAnimatedTransitioning)
        -> UIViewControllerInteractiveTransitioning? {
            return interactive ? self : nil
    }
    
    func interactionControllerForDismissal(animator: UIViewControllerAnimatedTransitioning)
        -> UIViewControllerInteractiveTransitioning? {
            return interactive ? self : nil
    }
}