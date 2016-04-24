//
//  MenuTransitionManager.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 2/28/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation

/**
 Object that controls transition from main screen to menu and back using gesture recognizers.
 To use it you need to pass new instance of MenuTransitionManager to a controller that is presented,
 set a sourceViewController and menuViewController.
 */
class MenuTransitionManager: UIPercentDrivenInteractiveTransition {
    
    /// UIViewController from which transition happens
    var sourceViewController: UIViewController? { didSet { setupEnterGesture() } }
    
    /// UIViewController destination
    var menuViewController: UIViewController? { didSet { setupExitGesture() } }
    
    private var presenting = false
    private var interactive = false
    private var enterPanGesture: UIScreenEdgePanGestureRecognizer?
    private var exitPanGesture: UIPanGestureRecognizer?
    
    private enum TransitionDirection {
        case Onstage
        case Offstage
    }
    
    /**
     Method that handles interactive transition to presenting menu controller
     
     - parameter pan: UIPanGestureRecognizer of the onscreen view controller
     */
    func handleOnstagePan(pan: UIPanGestureRecognizer) {
        handleTransition(inDirection: .Onstage, recognizer: pan)
    }
    
    /**
     Method that handles returning transition to initial state from menu controller
     
     - parameter pan: UIPanGestureRecognizer of the menu controller
     */
    func handleOffstagePan(pan: UIPanGestureRecognizer) {
        handleTransition(inDirection: .Offstage, recognizer: pan)
    }
    
    private func setupEnterGesture() {
        enterPanGesture = UIScreenEdgePanGestureRecognizer()
        enterPanGesture?.addTarget(self, action: #selector(MenuTransitionManager.handleOnstagePan(_:)))
        enterPanGesture?.edges = UIRectEdge.Left
        
        if let recoginzer = enterPanGesture {
            sourceViewController?.view.addGestureRecognizer(recoginzer)
        }
    }
    
    private func setupExitGesture() {
        exitPanGesture = UIPanGestureRecognizer()
        exitPanGesture?.addTarget(self, action: #selector(MenuTransitionManager.handleOffstagePan(_:)))
        
        if let recognizer = exitPanGesture {
            menuViewController?.view.addGestureRecognizer(recognizer)
        }
    }
    
    private func handleTransition(inDirection direction: TransitionDirection, recognizer: UIPanGestureRecognizer) {
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
            
            guard let mainScreen = sourceViewController as? MainScreenVC else {
                return
            }
            
            let menuVC: MenuVC = ControllerFactory.createController()
            menuVC.transitioningDelegate = mainScreen.transitionManager
            menuViewController = menuVC
            sourceViewController?.presentViewController(menuVC, animated: true, completion: nil)
        } else {
            menuViewController?.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    private func progressForPanGesture(inRecognizer recognizer: UIPanGestureRecognizer, direction: TransitionDirection) -> CGFloat {
        guard let view = recognizer.view else { return 0 }
        let screenTranslationAdjustment: CGFloat = direction == .Onstage ? 0.5 : -0.5
        let translation = recognizer.translationInView(view)
        return translation.x / CGRectGetWidth(view.bounds) * screenTranslationAdjustment
    }
    
    private func finishTransition(withProgress progress: CGFloat, direction: TransitionDirection) {
        let minTransition: CGFloat = direction == .Onstage ? 0.3 : 0.1
        
        if progress > minTransition {
            finishInteractiveTransition()
        } else {
            cancelInteractiveTransition()
        }
    }
}

extension MenuTransitionManager: UIViewControllerAnimatedTransitioning {
    
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
        
        let menuController = !presenting ? controllers.top as! MenuVC : controllers.destination as! MenuVC
        let topController = !presenting ? controllers.destination as! MainScreenVC : controllers.top as! MainScreenVC
        topController.view.layer.shadowOpacity = 0.8
        
        let menuView = menuController.view
        let topView = topController.view
        
        if presenting {
            menuView.transform = offStage(-200)
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
    
    private func animateIntractiveTransition(inContext transitionContext: UIViewControllerContextTransitioning,
        duration: NSTimeInterval, menuView: UIView, topView: UIView, isPresenting: Bool) {
            
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
            topView.transform = self.offStage(CGRectGetWidth(topView.bounds) * 0.8)
        } else {
            topView.transform = CGAffineTransformIdentity
            menuView.transform = self.offStage(-200)
        }
    }
    
    private func offStage(amount: CGFloat) -> CGAffineTransform {
        return CGAffineTransformMakeTranslation(amount, 0)
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
        
        // fix for bug when second view dissapears from screen
        // use either that or adjust transform of the menu
        if isPresenting {
            UIApplication.sharedApplication().keyWindow?.addSubview(controllers.top.view)
        } else {
            UIApplication.sharedApplication().keyWindow?.addSubview(controllers.destination.view)
        }
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

extension MenuTransitionManager: UIViewControllerTransitioningDelegate {
    
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