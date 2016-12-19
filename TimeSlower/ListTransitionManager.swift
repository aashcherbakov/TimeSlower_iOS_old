//
//  ListTransitionManager.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 7/31/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation

class ListTransitionManager: UIPercentDrivenInteractiveTransition {
    
    fileprivate enum TransitionDirection {
        case onstage
        case offstage
    }
    
    var sourceController: UIViewController? { didSet { setupEnterGesture() } }
    var activityListController: UIViewController? { didSet { setupExitGesture() } }
    
    fileprivate var presenting = false
    fileprivate var interactive = false
    fileprivate var enterGesture: UIPanGestureRecognizer?
    fileprivate var exitGesture: UIPanGestureRecognizer?
    
    fileprivate let screenHeight = UIScreen.main.bounds.height
    
    func handleOnstagePan(_ pan: UIPanGestureRecognizer) {
        handleTransitionInDirection(.onstage, recognizer: pan)
    }
    
    func handleOffstagePan(_ pan: UIPanGestureRecognizer) {
        handleTransitionInDirection(.offstage, recognizer: pan)
    }
    
    fileprivate func setupEnterGesture() {
        let enterGesture = UIPanGestureRecognizer()
        enterGesture.addTarget(self, action: #selector(ListTransitionManager.handleOnstagePan(_:)))
        sourceController?.view.addGestureRecognizer(enterGesture)
    }
    
    fileprivate func setupExitGesture() {
        let exitGesture = UIPanGestureRecognizer()
        exitGesture.addTarget(self, action: #selector(ListTransitionManager.handleOffstagePan(_:)))
        activityListController?.view.addGestureRecognizer(exitGesture)
    }
    
    fileprivate func handleTransitionInDirection(_ direction: TransitionDirection, recognizer: UIPanGestureRecognizer) {
        
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
    
    fileprivate func progressForPanGesture(inRecognizer recognizer: UIPanGestureRecognizer, direction: TransitionDirection) -> CGFloat {
        
        guard let view = recognizer.view else { return 0 }
        let screenTranslationAdjustment: CGFloat = direction == .onstage ? 0.5 : -0.5
        let translation = recognizer.translation(in: view)
        return -translation.y / view.bounds.height * screenTranslationAdjustment
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
            guard let currentVC = sourceController as? HomeViewController else {
                return
            }
            
            let listController: ActivitiesList = ControllerFactory.createController()
            listController.presentedModally = true
            let navigationController = UINavigationController(rootViewController: listController)
            navigationController.transitioningDelegate = currentVC.activityListTransitionManager
            
            activityListController = navigationController
            sourceController?.present(navigationController, animated: true, completion: nil)
        } else {
            activityListController?.dismiss(animated: true, completion: nil)
        }
    }
    
    fileprivate func finishTransition(withProgress progress: CGFloat, direction: TransitionDirection) {
        let minTransition: CGFloat = direction == .onstage ? 0.1 : 0.1
        if progress > minTransition {
            finish()
        } else {
            cancel()
        }
    }
}

extension ListTransitionManager: UIViewControllerAnimatedTransitioning {
    
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
            menuView.transform = offStage(screenHeight)
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
        
        UIView.animate(withDuration: duration, delay: 0.0,
                                   usingSpringWithDamping: 0.9,
                                   initialSpringVelocity: 0.2,
                                   options: [],
                                   animations: { [weak self] in
                self?.performViewTransformations(ifPresenting: isPresenting, menuView: menuView, topView: topView)
            }, completion: { [weak self] finished in
                self?.completeInteractiveTransition(inContext: transitionContext, isPresenting: isPresenting)
            })
    }
    
    // MARK: - Transformation Helpers
    
    fileprivate func performViewTransformations(ifPresenting presenting: Bool, menuView: UIView, topView: UIView) {
        if presenting {
            menuView.transform = CGAffineTransform.identity
            topView.transform = self.offStage(-screenHeight)
        } else {
            topView.transform = CGAffineTransform.identity
            menuView.transform = self.offStage(screenHeight)
        }
    }
    
    fileprivate func offStage(_ amount: CGFloat) -> CGAffineTransform {
        return CGAffineTransform(translationX: 0, y: amount)
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

extension ListTransitionManager: UIViewControllerTransitioningDelegate {
    
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
