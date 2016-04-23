//
//  MainScreenContainerVC.swift
//  TimeSlower2
//
//  Created by Oleksandr Shcherbakov on 7/31/15.
//  Copyright (c) 2015 1lastDay. All rights reserved.
//

import UIKit

class MainScreenContainerVC: UIViewController {

    struct Constants {
        static let menuOffsetScale: CGFloat = 0.23
    }
    
    enum SlideOutState {
        case Default
        case MenuExpended
    }
    
    var mainNavigationController: UINavigationController!
    
    var mainScreenController: MainScreenVC!
    
    var menuViewController: MenuVC?
    
    var currentState: SlideOutState = .Default {
        didSet {
            let shouldShowShadow = currentState != .Default
            showShadowForMainVC(shouldShowShadow)
        }
    }
    
    private lazy var menuStoryboard: UIStoryboard = {
        return UIStoryboard(name: "Menu", bundle: nil)
    }()

    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMainVC()
    }
    
    func setupMainVC() {
        navigationController?.navigationBarHidden = true
        let mainScreen: MainScreenVC = ControllerFactory.createController()
        mainScreenController = mainScreen
        mainScreenController.delegate = self
        mainNavigationController = UINavigationController(rootViewController: mainScreenController)
        view.addSubview(mainNavigationController.view)
        addChildViewController(mainNavigationController)
        mainNavigationController.didMoveToParentViewController(self)
    }
}

extension MainScreenContainerVC: MainScreenVCDelegate {
    
    func collapseMenu() {
        toggleMenuWithDelay(0.1)
    }
    
    func toggleMenuWithDelay(delay: Double) {
        let notAlreadyExpanded = (currentState != .MenuExpended)
        if notAlreadyExpanded {
//            addMenuViewController()
        }
        animateMenuVC(shouldExpand: notAlreadyExpanded, delay: delay)
    }
    
//    func addMenuViewController() {
//        if menuViewController == nil {
//            let menu
//            menuViewController = UIStoryboard.menuViewController()
//            menuViewController!.delegate = mainScreenController
//            view.insertSubview(menuViewController!.view, atIndex: 0)
//            addChildViewController(menuViewController!)
//            menuViewController?.didMoveToParentViewController(self)
//        }
//    }
    
    func animateMenuVC(shouldExpand shouldExpand: Bool, delay: Double) {
        let menuExpendedOffset = kUsableViewWidth * Constants.menuOffsetScale
        if shouldExpand {
            currentState = .MenuExpended
            animateMainScreenXPosition(targetPosition: CGRectGetWidth(mainNavigationController.view.frame) - menuExpendedOffset, delay: delay)
        } else {
            animateMainScreenXPosition(targetPosition: 0, delay: delay) { finished in
                self.currentState = .Default
                self.menuViewController!.view.removeFromSuperview()
                self.menuViewController = nil
            }
        }
    }
    
    func animateMainScreenXPosition(targetPosition targetPosition: CGFloat, delay: Double, completion: ((Bool) -> Void)! = nil) {
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: {
            self.mainNavigationController.view.frame.origin.x = targetPosition
        }, completion: completion)
    }

    
    func showShadowForMainVC(shouldShow: Bool) {
        mainNavigationController.view.layer.shadowOpacity = shouldShow ? 0.8 : 0
    }
}


