//
//  EditActivityViewController.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 5/30/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import UIKit
import ReactiveCocoa
import TimeSlowerKit

/// Controller that is responsible for editing/entering information about given activity
internal class EditActivityVC: UIViewController {
    
    private struct Constants {
        static let numberOfRows = 5
        static let defaultCellHeight: CGFloat = 50
    }
    
    /**
     Depending on whether controller has been passed an Activity instance, user will either edit it or create new one
     
     - Editing: Editing activity.
     - Creating: Creating activity. Starting with Name. End state is like start state of Editing
     */
    enum Flow {
        case Editing
        case Creating
    }
    
    enum EditingState: Int {
        case Name
        case Basis
        case StartTime
        case Duration
        case FullHouse
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var timeSaverView: TimeSaver!
    @IBOutlet weak var titleLabel: UILabel!
    
    var flow: Flow?
    var editingState: EditingState?
    var userProfile: Profile?
    dynamic var activity: Activity?
    var activityManager = ActivityManager()
    
    typealias StateType = EditingState
    private var machine: StateMachine<EditActivityVC>!
    
    // MARK: - Activity Properties and ValueSignals
    var selectedName: String?
    var selectedBasis: [Int]?
    var selectedStartTime: NSDate?
    var selectedDuration: ActivityDuration?
    var selectedNotifications: Bool? = true
    var selectedTimeToSave: Int?
    
    var nameSignal: SignalProducer<AnyObject?, NSError>?
    var basisSignal: SignalProducer<AnyObject?, NSError>?
    var startTimeSignal: SignalProducer<AnyObject?, NSError>?
    var durationSignal: SignalProducer<AnyObject?, NSError>?
    var notificationsSignal: SignalProducer<AnyObject?, NSError>?
    var timeToSaveSignal: SignalProducer<AnyObject?, NSError>?
    
    var valueSignals = [SignalProducer<AnyObject?, NSError>]()
    var initialValuesForCells: [AnyObject?]?
    private var footerView: UIView?
    
    dynamic private var lastExpandedCellIndex: NSIndexPath?
    private var expandedCellIndex: NSIndexPath? {
        willSet {
            var nextIndex = newValue
            if nextIndex == lastExpandedCellIndex {
                nextIndex = nil
            }
            
            resignNameTextfieldAsFirstResponder()
            
            UIView.animateWithDuration(0.3) {
                self.tableView.beginUpdates()
                self.lastExpandedCellIndex = nextIndex
                self.tableView.endUpdates()
            }
        }
    }
    
    // MARK: - Overridden
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupEvents()
        setupDesign()
    }
    
    // MARK: - Actions
    
    @IBAction func backButtonTapped(sender: AnyObject) {
        if let navigationController = navigationController {
            navigationController.popViewControllerAnimated(true)
        } else {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    @IBAction func okButtonTapped(sender: AnyObject) {
        if flow == .Creating && editingState == .FullHouse {
            if expandedCellIndex == nil {
                createActivity()
                showStatsInActivityMotivationVC()
            } else {
                expandedCellIndex = nil
            }
            
        } else if flow == .Editing {
            if expandedCellIndex == nil {
                saveActivity()
                showStatsInActivityMotivationVC()
            } else {
                expandedCellIndex = nil
            }
        } else {
            forceMoveToNextControl()
        }
    }
    
    private func createActivity() {
        guard let name = selectedName, basis = selectedBasis, startTime = selectedStartTime, duration = selectedDuration,
            notifications = selectedNotifications, timeToSave = selectedTimeToSave, profile = userProfile else {
            // TODO: submit notification that something is missing
            return
        }
        
        // TODO: switch to check type
        activity = activityManager.createActivityWithType(.Routine, name: name, selectedDays: basis, startTime: startTime,
            duration: duration, notifications: notifications, timeToSave: timeToSave, forProfile: profile)
    }
    
    private func saveActivity() {
        guard let activity = activity, name = selectedName, basis = selectedBasis, startTime = selectedStartTime, duration = selectedDuration, notifications = selectedNotifications, timeToSave = selectedTimeToSave else {
                return
        }
        
        activityManager.updateActivityWithParameters(activity, name: name, selectedDays: basis, startTime: startTime,
            duration: duration, notifications: notifications, timeToSave: timeToSave)
    }
    
    // MARK: - Private Functions
    
    private func setupDesign() {
        if activity != nil {
            flow = .Editing
            editingState = .FullHouse
            timeSaverView.selectedDuration = activity?.timing.duration
            timeSaverView.selectedValue = ActivityDuration(value: (activity?.timing.timeToSave.integerValue)!, period: (activity?.timing.duration.period)!)
        } else {
            flow = .Creating
            editingState = .Name
            machine = StateMachine(withState: .Name, delegate: self)
            timeSaverView.alpha = 0
        }
        
        footerView = tableFooterView()
        tableView.tableFooterView = footerView
        titleLabel.text = (activity != nil) ? "Edit activity" : "New activity"
    }
    
    private func setupData() {
        if let activity = activity {
            selectedName = activity.name
            selectedBasis = Day.daysIntegerRepresentation(activity.days as? Set<Day>)
            selectedStartTime = activity.timing.startTime
            selectedDuration = activity.timing.duration
            selectedNotifications = activity.notifications.boolValue
            selectedTimeToSave = activity.timing.timeToSave.integerValue
            
            initialValuesForCells = [selectedName, selectedBasis, selectedStartTime, selectedDuration, selectedNotifications]
        }
    }
    
    private func tableFooterView() -> UIView {
        let frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 50)
        let image = UIImage(named: "whiteCurve")
        let view = UIView(frame: frame)
        let imageView = UIImageView(frame: frame)
        imageView.contentMode = .ScaleToFill
        imageView.image = image
        view.addSubview(imageView)
        return view
    }
    
    // MARK: - Events
    
    private func setupEvents() {
        tableView.dataSource = self
        tableView.delegate = self
        
        rac_valuesForKeyPath("activity", observer: self).toSignalProducer().startWithNext { [weak self] (_) in
            self?.setupData()
            
        }
        
        changeTimeSaverVisibilityWhenCellExpands()
        trackTimeSaverValueChanges()
    }
    
    private func changeTimeSaverVisibilityWhenCellExpands() {
        rac_valuesForKeyPath("lastExpandedCellIndex", observer: self).toSignalProducer()
            .startWithNext { [weak self] (value) in
                if self?.editingState == .FullHouse {
                    self?.timeSaverView.alpha = value == nil ? 1 : 0
                }
        }
    }
    
    private func trackTimeSaverValueChanges() {
        timeSaverView.rac_valuesForKeyPath("selectedValue", observer: self).startWith(timeSaverView)
            .toSignalProducer()
            .startWithNext { [weak self] (timeToSave) in
                guard let timeToSave = timeToSave as? ActivityDuration else { return }
                self?.selectedTimeToSave = timeToSave.minutes()
        }
    }
    
    private func mapValueSignals() {
        nameSignal = valueSignals[EditRow.Name.rawValue]
        basisSignal = valueSignals[EditRow.Basis.rawValue]
        startTimeSignal = valueSignals[EditRow.StartTime.rawValue]
        durationSignal = valueSignals[EditRow.Duration.rawValue]
        notificationsSignal = valueSignals[EditRow.Notifications.rawValue]
    }
    
    private func startTrackingValueChanges() {
        guard
            let nameSignal = nameSignal, basisSignal = basisSignal, startTimeSignal = startTimeSignal,
            durationSignal = durationSignal, notificationsSignal = notificationsSignal
        else {
            return
        }
        
        durationSignal.startWithNext { [weak self] (value) in
            guard let duration = value as? ActivityDuration else { return }
            self?.timeSaverView.selectedDuration = duration
        }
        
        combineLatest(nameSignal, basisSignal, startTimeSignal, durationSignal, notificationsSignal)
            .startWithNext { [weak self] (name, basis, startTime, duration, notification) in
                self?.selectedName = name as? String
                self?.selectedBasis = basis as? [Int]
                self?.selectedStartTime = startTime as? NSDate
                self?.selectedDuration = duration as? ActivityDuration
                self?.selectedNotifications = notification as? Bool
                self?.moveToNextEditingState()
        }
    }
    
    // MARK: - Update state
    
    private func moveToNextEditingState() {
        guard let state = editingState, nextState = EditingState(rawValue: state.rawValue + 1) else { return }
        machine.state = nextState
    }
    
    private func forceMoveToNextControl() {
        guard let lastIndex = lastExpandedCellIndex, currentCell = tableView.cellForRowAtIndexPath(lastIndex)
            as? ObservableControlCell else { return }
        
        currentCell.control.touchesEnded([UITouch()], withEvent: nil)
    }
    
    private func expandNextCell() {
        guard let currentRow = expandedCellIndex?.row, currentSection = expandedCellIndex?.section else {
            return
        }
        
        let nextRow = currentRow + 1
        if nextRow <= Constants.numberOfRows {
            let nextIndexPath = NSIndexPath(forRow: nextRow, inSection: currentSection)
            expandedCellIndex = nextIndexPath
        } else {
            expandedCellIndex = nil
        }
    }
    
    private func resignNameTextfieldAsFirstResponder() {
        guard let
            lastExpandedCellIndex = lastExpandedCellIndex,
            cell = tableView.cellForRowAtIndexPath(lastExpandedCellIndex) as? EditNameCell,
            control = cell.control as? EditActivityNameView
            else {
                return
        }
        
        control.textFieldView.textField.resignFirstResponder()
    }
    
    private func showStatsInActivityMotivationVC() {
        guard let activity = activity else {
            return
        }
        
        let motivationVC: MotivationViewController = ControllerFactory.createController()
        motivationVC.setupWithActivity(activity)
        
        if let navigationController = navigationController {
            navigationController.pushViewController(motivationVC, animated: true)
        } else {
            presentViewController(motivationVC, animated: true, completion: nil)
        }
    }
    
    func alertUserOnMissingData(message message: String) {
        let alert = UIAlertController(title: "Oops!", message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
}

extension EditActivityVC: StateMachineDelegate {
    func shouldTransitionFrom(from: StateType, to: StateType) -> Bool {
        switch (from, to) {
        case (.Name, .Basis): return selectedName != nil
        case (.Basis, .StartTime): return selectedBasis != nil
        case (.StartTime, .Duration): return selectedStartTime != nil
        case (.Duration, .FullHouse): return selectedDuration != nil
        default: return false
        }
    }
    
    func didTransitionFrom(from: StateType, to: StateType) {
        editingState = to
        expandNextCell()
        
        if to == .FullHouse {
            timeSaverView.alpha = 1
        }
    }
}

// MARK: - UITableViewDelegate

extension EditActivityVC: UITableViewDelegate {
    
    private enum EditRow: Int {
        case Name = 0
        case Basis
        case StartTime
        case Duration
        case Notifications
        
        func expandableCellType() -> ExpandableCell.Type {
            switch self {
            case Name: return EditNameCell.self
            case Basis: return EditBasisCell.self
            case StartTime: return EditStartTimeCell.self
            case Duration: return EditDurationCell.self
            case Notifications: return EditNotificationsCell.self
            }
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        guard let selectedRow = EditRow(rawValue: indexPath.row) else { return 0 }
        
        let expandableType = selectedRow.expandableCellType()
        if indexPath == lastExpandedCellIndex {
            return expandableType.expandedHeight
        } else {
            if let state = editingState {
                return expandableType.heightForState(state)
            } else {
                return expandableType.defaultHeight()
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension EditActivityVC: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Constants.numberOfRows
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let
            editRow = EditRow(rawValue: indexPath.row),
            cell = tableView.dequeueReusableCellWithIdentifier(String(editRow.expandableCellType())) as? ObservableControlCell,
            valueSignal = cell.signalForValueChange()
        else {
            return UITableViewCell()
        }
        
        if let values = initialValuesForCells where values.count == Constants.numberOfRows {
            cell.control.setInitialValue(values[indexPath.row])
        }
        
        cell.control.rac_signalForControlEvents(.TouchUpInside).toSignalProducer()
            .observeOn(UIScheduler())
            .startWithNext { [weak self] (_) in
                if let cell = cell as? UITableViewCell {
                    self?.expandedCellIndex = self?.tableView.indexPathForCell(cell)
                }
        }
        
        valueSignals.insert(valueSignal, atIndex: indexPath.row)
        mapValueSignalsForIndexPath(indexPath)
        return cell as! UITableViewCell
    }
    
    private func mapValueSignalsForIndexPath(indexPath: NSIndexPath) {
        if indexPath.row == EditRow.Notifications.rawValue {
            mapValueSignals()
            startTrackingValueChanges()
        }
    }
}