//
//  EditActivityVC.swift
//  TimeSlower2
//
//  Created by Aleksander Shcherbakov on 5/5/15.
//  Copyright (c) 2015 1lastDay. All rights reserved.
//

import UIKit
import TimeSlowerKit
import RxSwift
import RxCocoa


class EditActivityVC: EditActivityVCConstraints {

    @IBOutlet weak var timeSaver: TimeSaver!
    @IBOutlet weak var editingDataView: EditActivityDataView!
    
    var selectedBasis: ActivityBasis?
    var userProfile: Profile?
//    var activity: Activity?
    
    private var selectedIndexPath: NSIndexPath?
    
    private var viewModel: EditActivityViewModel?
    private let disposableBag = DisposeBag()

    lazy var dateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeStyle = .ShortStyle
        dateFormatter.dateStyle = .NoStyle
        return dateFormatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupData()
        setupDesign()
        setupEvents()
    }
    
    private func setupData() {
        viewModel = EditActivityViewModel(withDataView: editingDataView, timeSaver: timeSaver)
    }
    
    private func setupDesign() {
        if let viewModel = viewModel {
            topWhiteViewHeight.constant = viewModel.updatedContentSizeHeight.value + 24
        }
    }
    
    private func setupEvents() {
        viewModel?.updatedContentSizeHeight
            .subscribeNext { [weak self] (height) -> Void in
                self?.topWhiteViewHeight.constant = height + 24
                UIView.animateWithDuration(0.3) {
                    self?.view.layoutIfNeeded()
                }
            }
            .addDisposableTo(disposableBag)
    }
    
    //MARK: - Action
    
    @IBAction func backButtonTapped(sender: AnyObject) {
        if let parentController = navigationController {
            parentController.popViewControllerAnimated(true)
        } else {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    @IBAction func doneButtonPressed() {
        let isItSafe = allDataEntered()
        
        if isItSafe.0 {
            saveActivity()
            showStatsInActivityMotivationVC()
            
        } else {
            alertUserOnMissingData(message: isItSafe.1)
        }
    }
    
    private func showStatsInActivityMotivationVC() {
        if let motivationVC = self.storyboard?
            .instantiateViewControllerWithIdentifier(ActivityMotivationVC.className) as? ActivityMotivationVC {
                motivationVC.activity = self.activity
                presentViewController(motivationVC, animated: true, completion: nil)
        }
    }
    
    func allDataEntered() -> (Bool, String) {
//        if textField.text == "" {
//            return (false, "Activity has no name!")
//        }
//        if startTimeValueLabel.text == "" {
//            return (false, "Start time is not selected!")
//        }
        return (true, "")
    }
    
    func alertUserOnMissingData(message message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    
    func saveActivity() {
        if activity == nil {
            let newActivity = Activity.newActivityForProfile(userProfile!, ofType: .Routine)
            activity = newActivity
        }
        
//        activity?.name = textField.text!
//        let selectedBasis = ActivityBasis(rawValue:basisSelector.selectedSegmentIndex!)
//        activity?.basis = Activity.basisWithEnum(selectedBasis!)
//        activity?.timing.startTime = Timing.updateTimeForToday(datePicker.date)
//        activity?.timing.duration = NSNumber(double: activityDuration)
//        activity?.timing.finishTime = activity!.timing.startTime.dateByAddingTimeInterval(activity!.timing.duration.doubleValue * 60)
//        activity?.timing.timeToSave = NSNumber(float: timeSaver.slider.value)
        
        do {
            try activity!.managedObjectContext!.save()
        } catch let error as NSError {
            print("Could not save: \(error)") }
        
        activity?.scheduleDefaultStartNotification()
        print("Created activity description: \(activity!)")
    }
    
    // MARK: - Navigation


    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "Summ Up Stats" {
            if let vc = segue.destinationViewController as? ActivityMotivationVC {
                vc.activity = self.activity
            }
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    @IBAction func editingComplete(segue: UIStoryboardSegue) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

