//
//  EditActivityVC.swift
//  TimeSlower2
//
//  Created by Aleksander Shcherbakov on 5/5/15.
//  Copyright (c) 2015 1lastDay. All rights reserved.
//

import UIKit
import TimeSlowerKit

class EditActivityVC: EditActivityVCConstraints {

    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var timeSaver: TimeSaver!
    @IBOutlet weak var basisSelector: BasisSelector!
    @IBOutlet weak var basisDaysView: DaySelector!
    @IBOutlet weak var durationValueLabel: UILabel!
    @IBOutlet weak var notificationSwith: UISwitch!
    @IBOutlet weak var startTimeValueLabel: UILabel!
    @IBOutlet weak var defaultActivityPicker: DefaultActivitySelector!
    
    var activityDuration: Double = 30.0 {
        didSet {
            if durationValueLabel != nil {
                let format = ".0"
                durationValueLabel.text = "\(activityDuration.format(format)) min"
            }
        }
    }
    var startTime: NSDate! {
        didSet {
            startTimeValueLabel.text = dateFormatter.stringFromDate(startTime)
        }
    }

    var selectedBasis: ActivityBasis!
    var userProfile: Profile!

    lazy var dateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeStyle = .ShortStyle
        dateFormatter.dateStyle = .NoStyle
        return dateFormatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCustomControls()

        defaultActivityPicker.typeToDisplay = .Routines
        
        defaultActivityPicker.addTarget(self, action: Selector("defaultActivitySelected:"), forControlEvents: .ValueChanged)
        basisDaysView.addTarget(self, action: Selector("backToBasisSelector"), forControlEvents: .TouchUpInside)
        basisSelector.addTarget(self, action: Selector("basisSelectorTapped:"), forControlEvents: .ValueChanged)

        if activity != nil {
            editingState = .Default
            displayActivityData()
        }
    }
    
    func setupCustomControls() {
        basisSelector.selectedSegmentIndex = 0
        selectedBasis = ActivityBasis(rawValue: basisSelector.selectedSegmentIndex!)
    }
    
    func displayActivityData() {
        textField.text = activity?.name
        timeSaver.sliderValue = activity!.timing.timeToSave.doubleValue
        basisSelector.selectedSegmentIndex = activity!.activityBasis().rawValue
    }
    
    //MARK: - Action
    
    @IBAction func tapedOnStartTime(sender: UITapGestureRecognizer) {
        editingState = (editingState == .Default) ? .StartTime : .Default
    }
    
    func backToBasisSelector() {
        editingState = .Default
    }
    
    func defaultActivitySelected(value: Int) {
        textField.text = defaultActivityPicker.selectedActivityName
        textField.resignFirstResponder()
        editingState = .Default
    }
    
    @IBAction func durationButtonPressed(sender: UIButton) {
        if sender.tag == 1 {
            activityDuration += 5.0
        } else if sender.tag == 0 {
            activityDuration -= 5.0
        }
    }

    @IBAction func changedStartTime(sender: UIDatePicker) {
        startTime = sender.date
    }

    @IBAction func doneButtonPressed() {
        
        if editingState == .StartTime {
            editingState = .Default
        } else if editingState == .Default {
            let isItSafe = allDataEntered()
            
            if isItSafe.0 {
                saveActivity()
                performSegueWithIdentifier("Summ Up Stats", sender: self)
            } else {
                alertUserOnMissingData(message: isItSafe.1)
            }
        }
    }
    
    func allDataEntered() -> (Bool, String) {
        if textField.text == "" {
            return (false, "Activity has no name!")
        }
        if startTimeValueLabel.text == "" {
            return (false, "Start time is not selected!")
        }
        return (true, "")
    }
    
    func alertUserOnMissingData(message message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func basisSelectorTapped(sender: BasisSelector) {
        basisDaysView.basis = ActivityBasis(rawValue: sender.selectedSegmentIndex!)
        editingState = .BasisDetail
    }
    
    @IBAction func basisChanged(sender: UISegmentedControl) {
    }
    
    func saveActivity() {
        if activity == nil {
            let newActivity = Activity.newActivityForProfile(userProfile, ofType: .Routine)
            activity = newActivity
        }
        
        activity?.name = textField.text!
        let selectedBasis = ActivityBasis(rawValue:basisSelector.selectedSegmentIndex!)
        activity?.basis = Activity.basisWithEnum(selectedBasis!)
        activity?.timing.startTime = Timing.updateTimeForToday(datePicker.date)
        activity?.timing.duration = NSNumber(double: activityDuration)
        activity?.timing.finishTime = activity!.timing.startTime.dateByAddingTimeInterval(activity!.timing.duration.doubleValue * 60)
        activity?.timing.timeToSave = NSNumber(float: timeSaver.slider.value)
        
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

extension EditActivityVC: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        editingState = .Default
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        editingState = .NameOnly
    }

}


