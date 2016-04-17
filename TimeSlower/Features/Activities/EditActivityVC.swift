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
    var activity: Activity?
    
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
        viewModel = EditActivityViewModel(
            withDataView: editingDataView,
            timeSaver: timeSaver,
            activity: activity)
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
        guard let viewModel = viewModel else { return }
        
        let dataEntered = viewModel.isDataEntered()
        if let missingData = dataEntered.missingData {
            alertUserOnMissingData(message: missingData)
        } else {
            if viewModel.isEditingAnyField() {
                viewModel.resetEditingState()
            } else {
                if let model = dataEntered.model {
                    saveActivity(withBlankModel: model)
                    showStatsInActivityMotivationVC()
                }
            }
        }
    }
    
    private func showStatsInActivityMotivationVC() {
        if let motivationVC = self.storyboard?
            .instantiateViewControllerWithIdentifier(ActivityMotivationVC.className) as? ActivityMotivationVC {
                motivationVC.activity = self.activity
                presentViewController(motivationVC, animated: true, completion: nil)
        }
    }
    
    func alertUserOnMissingData(message message: String) {
        let alert = UIAlertController(title: "Oops!", message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    
    func saveActivity(withBlankModel model: ActivityBlankModel) {
        if activity == nil {
            let newActivity = Activity.newActivityForProfile(userProfile!, ofType: .Routine)
            activity = newActivity
        }
        
        activity?.name = model.name
        activity?.basis = Activity.basisWithEnum(model.basis)
        activity?.timing.startTime = Timing.updateTimeForToday(model.startTime)
        activity?.timing.duration = NSNumber(integer: model.duration)
        activity?.timing.finishTime = activity!.timing.startTime
            .dateByAddingTimeInterval(activity!.timing.duration.doubleValue * 60)
        activity?.timing.timeToSave = NSNumber(integer: model.timeToSave)
        
        // TODO: notification on/off needs to be saved somehow
        
        do {
            try activity!.managedObjectContext!.save()
        } catch let error as NSError {
            print("Could not save: \(error)") }
        
        activity?.scheduleDefaultStartNotification()
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

