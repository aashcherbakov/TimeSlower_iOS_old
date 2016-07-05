//
//  ActivityMotivationVC.swift
//  TimeSlower2
//
//  Created by Aleksander Shcherbakov on 5/8/15.
//  Copyright (c) 2015 1lastDay. All rights reserved.
//

import UIKit
import TimeSlowerKit

class ActivityMotivationVC: ActivityMotivationVCConstraints {

    //MARK: - Outlets
    @IBOutlet weak var titleLable: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var dotsView: UIView!
    
    //MARK: - Properties
    var activity: Activity! {
        didSet {
            lifeSavings = activity.stats!.plannedTimingInLifetime()
        }
    }
    var lifeSavings: Profile.LifeTime! {
        didSet {
            pageDots = [Int(lifeSavings.years), Int(lifeSavings.months), Int(lifeSavings.days), Int(lifeSavings.hours)]
            if lifeSavings.years > 1 {
                pageTitles.insert("YEARS", atIndex: 0)
            } else {
                pageDots.removeAtIndex(0)
            }
        }
    }
    let format = ".0"
    var pageTitles = ["MONTHS", "DAYS", "HOURS"]
    var pageDots = [Int]()
    var pageViewController: UIPageViewController!
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBarHidden = true
        setup()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setupPageDotsColors()
    }
    
    //MARK: - Setup
    func setup() {
        titleLable.text = activity.name
        startTimeLabel.text = dateFormatter.stringFromDate(activity.timing!.updatedStartTime())
        durationLabel.text = "\(activity.timing!.duration.doubleValue.format(format)) min"
        setupDescriptionLabel()
        setupPageViewController()
    }
    
    func setupPageDotsColors() {
        let pageController = UIPageControl.appearance()
        pageController.pageIndicatorTintColor = UIColor.darkRed()
        pageController.currentPageIndicatorTintColor = UIColor.whiteColor()
        pageController.backgroundColor = UIColor.clearColor()
    }
    
    func setupPageViewController() {
        pageViewController = storyboard?.instantiateViewControllerWithIdentifier("Page View Controller") as! UIPageViewController
        pageViewController.dataSource = self
        
        let startVC = self.viewControllerAtIndex(0) as! DotsPageViewController
        let viewControllers = [startVC]
        
        pageViewController.setViewControllers(viewControllers, direction: .Forward, animated: true, completion: nil)
        pageViewController.view.frame = dotsView.bounds
        addChildViewController(pageViewController)
        dotsView.addSubview(pageViewController.view)
        pageViewController.didMoveToParentViewController(self)
    }
    
    func viewControllerAtIndex(index: Int) -> UIViewController {
        if index != pageTitles.count {
            let vc: DotsPageViewController = storyboard?.instantiateViewControllerWithIdentifier("DotsContentViewController") as! DotsPageViewController
            vc.titleText = "\(pageDots[index])"
            vc.periodText = pageTitles[index]
            vc.pageIndex = index
            vc.dots = pageDots[index]
            return vc
        } else {
            let vc: ShareVC = storyboard?.instantiateViewControllerWithIdentifier("ShareViewController") as! ShareVC
            vc.lifeTime = self.lifeSavings
            return vc
        }
    }
    
    func setupDescriptionLabel() {
        let timeToSave = activity.timing!.timeToSave.doubleValue.format(format)
        let name = activity.name!.uppercaseString
        let basis = activity.activityBasisDescription()
        descriptionLabel.text = "CUTTING \(timeToSave) MIN OF \(name) \(basis) WILL SAVE FOR YOUR LIFETIME:"
    }
    
    //MARK: - Lazy instantiation
    lazy var dateFormatter: NSDateFormatter = {
       var dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .NoStyle
        dateFormatter.timeStyle = .ShortStyle
        return dateFormatter
    }()
    
    //MARK: - Actions
    @IBAction func saveButtonPressed() {
        navigationController?.popToRootViewControllerAnimated(true)
    }

    @IBAction func onBackButton(sender: UIButton) {
        navigationController?.popViewControllerAnimated(true)
    }
}

//MARK: - PageViewController delegate
extension ActivityMotivationVC: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        var index = 0
        
        if let vc = viewController as? DotsPageViewController {
            index = vc.pageIndex! as Int
        } else {
            index = pageTitles.count
        }
        
        if index == 0 || index == NSNotFound {
            return nil
        }
        
        index -= 1
        return viewControllerAtIndex(index)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        var index = 0
        if let vc = viewController as? DotsPageViewController {
            index = vc.pageIndex! as Int
        } else {
            index = pageTitles.count
        }
        
        if index == NSNotFound {
            return nil
        }
        
        index += 1
        if index == self.pageTitles.count + 1 {
            return nil
        }
        return viewControllerAtIndex(index)
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return pageTitles.count + 1
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
}
