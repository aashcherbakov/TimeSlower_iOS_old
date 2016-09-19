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
    
    fileprivate var presenting = false
    fileprivate var interactive = false
    fileprivate var enterPanGesture: UIScreenEdgePanGestureRecognizer?
    fileprivate var exitPanGesture: UIPanGestureRecognizer?
    
    fileprivate enum TransitionDirection {
        case onstage
        case offstage
    }
    
    /**
     Method that handles interactive transition to presenting menu controller
     
     - parameter pan: UIPanGestureRecognizer of the onscreen view controller
     */
    func handleOnstagePan(_ pan: UIPanGestureRecognizer) {
        handleTransition(inDirection: .onstage, recognizer: pan)
    }
    
    /**
     Method that handles returning transition to initial state from menu controller
     
     - parameter pan: UIPanGestureRecognizer of the menu controller
     */
    func handleOffstagePan(_ pan: UIPanGestureRecognizer) {
        handleTransition(inDirection: .offstage, recognizer: pan)
    }
    
    fileprivate func setupEnterGesture() {
        enterPanGesture = UIScreenEdgePanGestureRecognizer()
        enterPanGesture?.addTarget(self, action: #selector(MenuTransitionManager.handleOnstagePan(_:)))
        enterPanGesture?.edges = UIRectEdge.left
        
        if let recoginzer = enterPanGesture {
            sourceViewController?.view.addGestureRecognizer(recoginzer)
        }
    }
    
    fileprivate func setupExitGesture() {
        exitPanGesture = UIPanGestureRecognizer()
        exitPanGesture?.addTarget(self, action: #selector(MenuTransitionManager.handleOffstagePan(_:)))
        
        if let recognizer = exitPanGesture {
            menuViewController?.view.addGestureRecognizer(recognizer)
        }
    }
    
    fileprivate func handleTransition(inDirection direction: TransitionDirection, recognizer: UIPanGestureRecognizer) {
        let progress = progressForPanGesture(inRecognizer: recognizer, direction: direction)
        guard progress > 0 else {
            if recognizer.state == .ended {
                interactive = false
                cancel()
            }
            return
        }

        handleRecognizerState(recognizer.state, withProgress: progress, direction: direction)
    }
    
    fileprivate func handleRecognizerState(_ state: UIGestureRecognizerState, withProgress
        progress: CGFloat, direction: TransitionDirection) {
            switch state {
            case .began:
                interactive = true
                presentController(forDirection: direction)
                
            case .changed:
                update(progress)
                
            default: // .Canceled, .Ended etc.
                interactive = false
                finishTransition(withProgress: progress, direction: direction)
            }
    }
    
    fileprivate func presentController(forDirection direction: TransitionDirection) {
        if direction == .onstage {
            
            guard let mainScreen = sourceViewController as? HomeViewController else {
                return
            }
            
            let menuVC: MenuVC = ControllerFactory.createController()
            menuVC.transitioningDelegate = mainScreen.transitionManager
            menuViewController = menuVC
            sourceViewController?.present(menuVC, animated: true, completion: nil)
        } else {
            menuViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    fileprivate func progressForPanGesture(inRecognizer recognizer: UIPanGestureRecognizer, direction: TransitionDirection) -> CGFloat {
        guard let view = recognizer.view else { return 0 }
        let screenTranslationAdjustment: CGFloat = direction == .onstage ? 0.5 : -0.5
        let translation = recognizer.translation(in: view)
        return translation.x / view.bounds.width * screenTranslationAdjustment
    }
    
    fileprivate func finishTransition(withProgress progress: CGFloat, direction: TransitionDirection) {
        let minTransition: CGFloat = direction == .onstage ? 0.3 : 0.1
        
        if progress > minTransition {
            finish()
        } else {
            cancel()
        }
    }
}

extension MenuTransitionManager: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView

        guard let controllers = controllersFromContext(transitionContext) else {
            return
        }
        
        let menuController = !presenting ? controllers.top : controllers.destination
        let topController = !presenting ? controllers.destination : controllers.top
        topController.view.layer.shadowOpacity = 0.8
        
        let menuView = menuController.view!
        let topView = topController.view!
        
        if presenting {
            menuView.transform = offStage(-200)
        }
        
        container.addSubview(menuView)
        container.addSubview(topView)
        
        // This variable has to be initialized before calling animateInteractiveTransition
        let duration = transitionDuration(using: transitionContext)
        
        animateIntractiveTransition(
            inContext: transitionContext,
            duration: duration,
            menuView: menuView,
            topView: topView,
            isPresenting: presenting)
    }
    
    fileprivate func animateIntractiveTransition(
        inContext transitionContext: UIViewControllerContextTransitioning,
        duration: TimeInterval,
        menuView: UIView,
        topView: UIView,
        isPresenting: Bool) {
            
            UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.2, options: [],
                animations: { [weak self] in
                    self?.performViewTransformations(ifPresenting: isPresenting, menuView: menuView, topView: topView)
                }, completion: { [weak self] finished in
                    self?.completeInteractiveTransition(inContext: transitionContext, isPresenting: isPresenting)
                })
    }
    
    // MARK: - Transformation Helpers
    
    fileprivate func performViewTransformations(ifPresenting presenting: Bool, menuView: UIView, topView: UIView) {
        if presenting {
            // if you don't want menu to be centered in screen, use offStage nethod
            // menuView.transform = self.offStage(-CGRectGetWidth(menuView.bounds) * 0.1)
            menuView.transform = CGAffineTransform.identity
            topView.transform = self.offStage(topView.bounds.width * 0.8)
        } else {
            topView.transform = CGAffineTransform.identity
            menuView.transform = self.offStage(-200)
        }
    }
    
    fileprivate func offStage(_ amount: CGFloat) -> CGAffineTransform {
        return CGAffineTransform(translationX: amount, y: 0)
    }
    
    
    // MARK: - Transition Context manipulations
    
    fileprivate func completeInteractiveTransition(inContext transitionContext: UIViewControllerContextTransitioning, isPresenting: Bool) {
        guard let controllers = self.controllersFromContext(transitionContext) else { return }
        
        if transitionContext.transitionWasCancelled {
            controllers.top.view.isUserInteractionEnabled = true
            controllers.destination.view.isUserInteractionEnabled = false
            transitionContext.completeTransition(false)
            UIApplication.shared.keyWindow?.addSubview(controllers.top.view)
        } else {
            controllers.top.view.isUserInteractionEnabled = false
            controllers.destination.view.isUserInteractionEnabled = true
            transitionContext.completeTransition(true)
            UIApplication.shared.keyWindow?.addSubview(controllers.destination.view)
        }
        
        // fix for bug when second view dissapears from screen
        // http://openradar.appspot.com/radar?id=5320103646199808
        if isPresenting {
            UIApplication.shared.keyWindow?.addSubview(controllers.top.view)
        } else {
            UIApplication.shared.keyWindow?.addSubview(controllers.destination.view)
        }
    }
        
    fileprivate func controllersFromContext(_ transitionContext: UIViewControllerContextTransitioning) ->
        (top: UIViewController, destination: UIViewController)? {
            
            guard let
                topController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
                let destinationController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
                else {
                    return nil
            }
            return (topController, destinationController)
    }
}

extension MenuTransitionManager: UIViewControllerTransitioningDelegate {
    
    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
            self.presenting = true
            return self
    }
    
    func animationController(
        forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
            self.presenting = false
            return self
    }
    
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning)
        -> UIViewControllerInteractiveTransitioning? {
            return interactive ? self : nil
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning)
        -> UIViewControllerInteractiveTransitioning? {
            return interactive ? self : nil
    }
}
