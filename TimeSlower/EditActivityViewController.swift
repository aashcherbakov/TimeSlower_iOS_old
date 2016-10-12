//
//  EditActivityViewController.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 5/30/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveObjC
import ReactiveObjCBridge
import Result
import TimeSlowerKit

/// Controller that is responsible for editing/entering information about given activity
internal class EditActivityVC: UIViewController {
    
    fileprivate struct Constants {
        static let numberOfRows = 5
        static let defaultCellHeight: CGFloat = 50
        static let iPhone5CellHeight: CGFloat = 40
    }
    
    /**
     Depending on whether controller has been passed an Activity instance, user will either edit it or create new one
     
     - Editing: Editing activity.
     - Creating: Creating activity. Starting with Name. End state is like start state of Editing
     */
    enum Flow {
        case editing
        case creating
    }
    
    enum EditingState: Int {
        case name
        case basis
        case startTime
        case duration
        case fullHouse
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var timeSaverView: TimeSaver!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeSaverViewHeight: NSLayoutConstraint!
    
    var flow: Flow?
    var editingState: EditingState?
    var userProfile: Profile?
    var activity: MutableProperty<Activity>?
    
    typealias StateType = EditingState
    fileprivate var machine: StateMachine<EditActivityVC>!
    
    // MARK: - Activity Properties and ValueSignals
    var selectedName: String?
    var selectedBasis: [Int]?
    var selectedStartTime: Date?
    var selectedDuration: Endurance?
    var selectedNotifications: Bool? = true
    var selectedTimeToSave: Int?
    
    var nameSignal: SignalProducer<Any?, NoError>?
    var basisSignal: SignalProducer<Any?, NoError>?
    var startTimeSignal: SignalProducer<Any?, NoError>?
    var durationSignal: SignalProducer<Any?, NoError>?
    var notificationsSignal: SignalProducer<Any?, NoError>?
    var timeToSaveSignal: SignalProducer<Any?, NoError>?
    
    var valueSignals = [SignalProducer<Any?, NoError>]()
    var initialValuesForCells: [AnyObject?]?
    
    fileprivate var footerView: UIView?
    
    dynamic fileprivate var lastExpandedCellIndex: IndexPath?
    fileprivate var expandedCellIndex: IndexPath? {
        willSet {
            var nextIndex = newValue
            if nextIndex == lastExpandedCellIndex {
                nextIndex = nil
            }
            
            resignNameTextfieldAsFirstResponder()
            
            UIView.animate(withDuration: 0.3, animations: {
                self.tableView.beginUpdates()
                self.lastExpandedCellIndex = nextIndex
                self.tableView.endUpdates()
            }) 
        }
    }
    
    // MARK: - Overridden
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupEvents()
        setupDesign()
    }
    
    // MARK: - Actions
    
    @IBAction func backButtonTapped(_ sender: AnyObject) {
        if let navigationController = navigationController {
            navigationController.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func okButtonTapped(_ sender: AnyObject) {
        if flow == .creating && editingState == .fullHouse {
            if expandedCellIndex == nil {
                createActivity()
                showStatsInActivityMotivationVC()
            } else {
                expandedCellIndex = nil
            }
            
        } else if flow == .editing {
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
    
    fileprivate func createActivity() {
        guard
            let name = selectedName,
            let basis = selectedBasis,
            let startTime = selectedStartTime,
            let duration = selectedDuration,
            let notifications = selectedNotifications,
            let timeToSave = selectedTimeToSave,
            let profile = userProfile else {
                
            // TODO: submit notification that something is missing
            return
        }
        
        // TODO: switch to check type
//        activity = Activity.createActivityWithType(.routine, name: name, selectedDays: basis, startTime: startTime,
//            duration: duration, notifications: notifications, timeToSave: timeToSave, forProfile: profile)
    }
    
    fileprivate func saveActivity() {
        guard
            let activity = activity,
            let name = selectedName,
            let basis = selectedBasis,
            let startTime = selectedStartTime,
            let duration = selectedDuration,
            let notifications = selectedNotifications,
            let timeToSave = selectedTimeToSave else {
                return
        }
        
//        Activity.updateActivityWithParameters(activity, name: name, selectedDays: basis, startTime: startTime,
//            duration: duration, notifications: notifications, timeToSave: timeToSave)
    }
    
    // MARK: - Private Functions
    
    fileprivate func setupDesign() {
        setupTimeSaverHeight()
        
        if activity != nil {
            flow = .editing
            editingState = .fullHouse
//            timeSaverView.selectedDuration = activity?.value.timing.duration
//            timeSaverView.selectedValue = Endurance(value: Int((activity?.timing.timeToSave.int32Value)!), period: (activity?.timing.duration.period)!)
        } else {
            flow = .creating
            editingState = .name
            machine = StateMachine(withState: .name, delegate: self)
            timeSaverView.alpha = 0
        }
        
        footerView = tableFooterView()
        tableView.tableFooterView = footerView
        titleLabel.text = (activity != nil) ? "Edit activity" : "New activity"
    }
    
    private func setupTimeSaverHeight() {
        switch ScreenHight() {
        case .iPhone5:
            timeSaverViewHeight.constant = 100
        default:
            timeSaverViewHeight.constant = 140
        }
    }
    
    fileprivate func setupData() {
        if let activity = activity {
//            selectedName = activity.name
//            selectedBasis = Day.daysIntegerRepresentation(activity.days as? Set<Day>)
//            selectedStartTime = activity.timing.startTime
//            selectedDuration = activity.timing.duration
//            selectedNotifications = activity.notifications.boolValue
//            selectedTimeToSave = activity.timing.timeToSave.intValue
            
//            initialValuesForCells = [selectedName as Optional<AnyObject>, selectedBasis as Optional<AnyObject>, selectedStartTime as Optional<AnyObject>, selectedDuration, selectedNotifications as Optional<AnyObject>]
        }
    }
    
    fileprivate func tableFooterView() -> UIView {
        let screenHeight = ScreenHight()
        let height = screenHeight == ScreenHight.iPhone5 ? Constants.iPhone5CellHeight : Constants.defaultCellHeight
        let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: height)
        let image = UIImage(named: "whiteCurve")
        let view = UIView(frame: frame)
        let imageView = UIImageView(frame: frame)
        imageView.contentMode = .scaleToFill
        imageView.image = image
        view.addSubview(imageView)
        return view
    }
    
    // MARK: - Events
    
    fileprivate func setupEvents() {
        tableView.dataSource = self
        tableView.delegate = self
        
        activity?.producer.startWithResult { [weak self] (result) in
            self?.setupData()
        }
        
        changeTimeSaverVisibilityWhenCellExpands()
        trackTimeSaverValueChanges()
    }
    
    fileprivate func changeTimeSaverVisibilityWhenCellExpands() {
        rac_values(forKeyPath: "lastExpandedCellIndex", observer: self).toSignalProducer()
            .startWithResult { [weak self] (result) in
                guard let editingState = self?.editingState, let value = result.value else {
                    return
                }
                
                if editingState == .fullHouse {
                    self?.timeSaverView.alpha = value == nil ? 1 : 0
                }
        }
    }
    
    fileprivate func trackTimeSaverValueChanges() {
        timeSaverView.selectedValue.producer
            .startWithResult { [weak self] (timeToSave) in
                guard let timeToSave = timeToSave.value else { return }
                self?.selectedTimeToSave = timeToSave?.minutes()
        }
    }
    
    fileprivate func mapValueSignals() {
        nameSignal = valueSignals[EditRow.name.rawValue]
        basisSignal = valueSignals[EditRow.basis.rawValue]
        startTimeSignal = valueSignals[EditRow.startTime.rawValue]
        durationSignal = valueSignals[EditRow.duration.rawValue]
        notificationsSignal = valueSignals[EditRow.notifications.rawValue]
    }
    
    fileprivate func startTrackingValueChanges() {
        guard
            let nameSignal = nameSignal,
            let basisSignal = basisSignal,
            let startTimeSignal = startTimeSignal,
            let durationSignal = durationSignal,
            let notificationsSignal = notificationsSignal
        else {
            return
        }
    
        nameSignal.startWithValues { [weak self] (value) in
            self?.selectedName = value as? String
            self?.moveToNextEditingState()
        }
        
        basisSignal.startWithValues { [weak self] (value) in
            self?.selectedBasis = value as? [Int]
            self?.moveToNextEditingState()
        }
        
        startTimeSignal.startWithValues { [weak self] (value) in
            self?.selectedStartTime = value as? Date
            self?.moveToNextEditingState()
        }
        
        durationSignal.startWithResult { [weak self] (result) in
            guard let duration = result.value as? Endurance else { return }
            self?.timeSaverView.selectedDuration.value = duration
            self?.selectedDuration = duration
            self?.moveToNextEditingState()
        }
        
        notificationsSignal.startWithValues { [weak self] (value) in
            self?.selectedNotifications = value as? Bool
            self?.moveToNextEditingState()
        }
    }
    
    // MARK: - Update state
    
    fileprivate func moveToNextEditingState() {
        guard let state = editingState, let nextState = EditingState(rawValue: state.rawValue + 1) else { return }
        machine.state = nextState
    }
    
    fileprivate func forceMoveToNextControl() {
        guard let lastIndex = lastExpandedCellIndex, let currentCell = tableView.cellForRow(at: lastIndex)
            as? ObservableControlCell else { return }
        
        currentCell.control.touchesEnded([UITouch()], with: nil)
    }
    
    fileprivate func expandNextCell() {
        guard let currentRow = (expandedCellIndex as IndexPath?)?.row, let currentSection = (expandedCellIndex as IndexPath?)?.section else {
            return
        }
        
        let nextRow = currentRow + 1
        if nextRow <= Constants.numberOfRows {
            let nextIndexPath = IndexPath(row: nextRow, section: currentSection)
            expandedCellIndex = nextIndexPath
        } else {
            expandedCellIndex = nil
        }
    }
    
    fileprivate func resignNameTextfieldAsFirstResponder() {
        guard let
            lastExpandedCellIndex = lastExpandedCellIndex,
            let cell = tableView.cellForRow(at: lastExpandedCellIndex) as? EditNameCell,
            let control = cell.control as? EditActivityNameView
            else {
                return
        }
        
        control.textFieldView.textField.resignFirstResponder()
    }
    
    fileprivate func showStatsInActivityMotivationVC() {
        guard let activity = activity else {
            return
        }
        
        let motivationVC: MotivationViewController = ControllerFactory.createController()
        motivationVC.setupWithActivity(activity.value)
        
        if let navigationController = navigationController {
            navigationController.pushViewController(motivationVC, animated: true)
        } else {
            present(motivationVC, animated: true, completion: nil)
        }
    }
    
    func alertUserOnMissingData(_ message: String) {
        let alert = UIAlertController(title: "Oops!", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
}

extension EditActivityVC: StateMachineDelegate {
    func shouldTransitionFrom(_ from: StateType, to: StateType) -> Bool {
        switch (from, to) {
        case (.name, .basis): return selectedName != nil
        case (.basis, .startTime): return selectedBasis != nil
        case (.startTime, .duration): return selectedStartTime != nil
        case (.duration, .fullHouse): return selectedDuration != nil
        default: return false
        }
    }
    
    func didTransitionFrom(_ from: StateType, to: StateType) {
        editingState = to
        expandNextCell()
        
        if to == .fullHouse {
            timeSaverView.alpha = 1
        }
    }
}

// MARK: - UITableViewDelegate

extension EditActivityVC: UITableViewDelegate {
    
    fileprivate enum EditRow: Int {
        case name = 0
        case basis
        case startTime
        case duration
        case notifications
        
        func expandableCellType() -> ExpandableCell.Type {
            switch self {
            case .name: return EditNameCell.self
            case .basis: return EditBasisCell.self
            case .startTime: return EditStartTimeCell.self
            case .duration: return EditDurationCell.self
            case .notifications: return EditNotificationsCell.self
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let selectedRow = EditRow(rawValue: (indexPath as NSIndexPath).row) else { return 0 }
        
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Constants.numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let editRow = EditRow(rawValue: (indexPath as NSIndexPath).row),
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: editRow.expandableCellType())) as? ObservableControlCell,
            let valueSignal = cell.signalForValueChange()
        else {
            return UITableViewCell()
        }
        
        if let values = initialValuesForCells, values.count == Constants.numberOfRows {
            cell.control.setInitialValue(values[(indexPath as NSIndexPath).row])
        }
        
        cell.control.rac_signal(for: .touchUpInside).toSignalProducer()
            .observe(on: UIScheduler())
            .startWithResult { [weak self] (result) in
                if let cell = cell as? UITableViewCell {
                    self?.expandedCellIndex = self?.tableView.indexPath(for: cell)
            }
        }
        
        if indexPath.row < valueSignals.count {
            valueSignals.insert(valueSignal, at: indexPath.row)
        } else {
            valueSignals.append(valueSignal)
        }
        
        mapValueSignalsForIndexPath(indexPath)
        return cell as! UITableViewCell
    }
    
    fileprivate func mapValueSignalsForIndexPath(_ indexPath: IndexPath) {
        if (indexPath as NSIndexPath).row == EditRow.notifications.rawValue {
            mapValueSignals()
            startTrackingValueChanges()
        }
    }
}
