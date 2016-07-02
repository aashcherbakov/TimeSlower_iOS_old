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

protocol ObservableControlCell {
    weak var control: UIControl! { get }
}

protocol ExpandableCell {
    static var expandedHeight: CGFloat { get }
    static var defaultHeight: CGFloat { get }
    static func heightForState(state: EditActivityVC.EditingState) -> CGFloat
}

/// Controller that is responsible for editing/entering information about given activity
class EditActivityVC: UIViewController {
    
    private struct Constants {
        static let numberOfRows = 6
        static let defaultCellHeight: CGFloat = 50
    }
    
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
    
    var userProfile: Profile?
    var activity: Activity?
    
    typealias StateType = EditingState
    private var machine: StateMachine<EditActivityVC>!
    
    var selectedName: String?
    var selectedBasis: [Int]?
    var selectedStartTime: NSDate?
    var selectedDuration: Int?
    var selectedNotifications: Bool?
    var selectedTimeToSave: Int?
    
    var flow: Flow?
    var state: EditingState?
    
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
    
    // MARK: - Private Functions
    
    private func setupEvents() {
        tableView.dataSource = self
        tableView.delegate = self
        
        changeTimeSaverVisibilityWhenCellExpands()
        trackTimeSaverValueChanges()
    }
    
    private func setupDesign() {
        if activity != nil {
            flow = .Editing
            state = .FullHouse
        } else {
            flow = .Creating
            state = .Name
            machine = StateMachine(withState: .Name, delegate: self)
            timeSaverView.alpha = 0
        }
        
        footerView = tableFooterView()
        tableView.tableFooterView = footerView
    }
    
    
    private func tableFooterView() -> UIView {
        let frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 50)
        let image = UIImage(named: "whiteCurve")
        let view = UIView(frame: frame)
        let imageView = UIImageView(image: image)
        view.addSubview(imageView)
        return view
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
    
    // MARK: - Cells
    
    var nameSignal: SignalProducer<AnyObject?, NSError>?
    var basisSignal: SignalProducer<AnyObject?, NSError>?
    var startTimeSignal: SignalProducer<AnyObject?, NSError>?
    var durationSignal: SignalProducer<AnyObject?, NSError>?
    var notificationsSignal: SignalProducer<AnyObject?, NSError>?
    var timeToSaveSignal: SignalProducer<AnyObject?, NSError>?
    
    private func editNameCellFromTableView(tableView: UITableView) -> EditNameCell {
        let cell: EditNameCell = tableView.dequeueReusableCell()
        makeCellExpandableOnTouch(cell)
        
        let nameControl = cell.control as? EditActivityNameView
        nameSignal = nameControl?.rac_valuesForKeyPath("selectedValue", observer: self).toSignalProducer()
        
        return cell
    }

    
    private func editBasisCell(fromTableView tableView: UITableView) -> EditBasisCell {
        let cell: EditBasisCell = tableView.dequeueReusableCell()
        makeCellExpandableOnTouch(cell)
        
        let basisControl = cell.control as? EditActivityBasisView
        basisSignal = basisControl?.rac_valuesForKeyPath("selectedValue", observer: self).toSignalProducer()

        return cell
    }
    
    private func editStartTimeCell(fromTableView tableView: UITableView) -> EditStartTimeCell {
        let cell: EditStartTimeCell = tableView.dequeueReusableCell()
        makeCellExpandableOnTouch(cell)
        
        let startTimeControl = cell.control as? EditActivityStartTimeView
        startTimeSignal = startTimeControl?.rac_valuesForKeyPath("selectedValue", observer: self).toSignalProducer()
        
        return cell
    }
    
    private func editDurationCell(fromTableView tableView: UITableView) -> EditDurationCell {
        let cell: EditDurationCell = tableView.dequeueReusableCell()
        makeCellExpandableOnTouch(cell)
        
        let durationControl = cell.control as? EditActivityDurationView
        durationSignal = durationControl?.rac_valuesForKeyPath("selectedValue", observer: self).toSignalProducer()
        
        return cell
    }
    
    private func editNotificationCell(fromTableView tableView: UITableView) -> EditNotificationsCell {
        let cell: EditNotificationsCell = tableView.dequeueReusableCell()
        makeCellExpandableOnTouch(cell)
        
        let notificationControl = cell.control as? EditActivityNotificationsView
        notificationsSignal = notificationControl?.rac_valuesForKeyPath("selectedValue", observer: self).toSignalProducer()
        
        return cell
    }
    
    private func makeCellExpandableOnTouch(cell: ObservableControlCell) {
        cell.control.rac_signalForControlEvents(.TouchUpInside).toSignalProducer()
            .observeOn(UIScheduler())
            .startWithNext { [weak self] (_) in
                if let cell = cell as? UITableViewCell {
                    self?.expandedCellIndex = self?.tableView.indexPathForCell(cell)
                }
        }
    }
    
    // MARK: - TimeSaver tracking
    
    private func changeTimeSaverVisibilityWhenCellExpands() {
        rac_valuesForKeyPath("lastExpandedCellIndex", observer: self).toSignalProducer()
            .startWithNext { [weak self] (value) in
                if self?.state == .FullHouse {
                    self?.timeSaverView.alpha = value == nil ? 1 : 0
                }
        }
    }
    
    private func trackTimeSaverValueChanges() {
        timeSaverView.rac_valuesForKeyPath("selectedValue", observer: self).toSignalProducer()
            .startWithNext { [weak self] (timeToSave) in
                guard let timeToSave = timeToSave as? Int else { return }
                self?.selectedTimeToSave = timeToSave
        }
    }
    
    // MARK: - Update state
    
    private func startTrackingValueChanges() {
        guard
            let nameSignal = nameSignal, basisSignal = basisSignal, startTimeSignal = startTimeSignal,
            durationSignal = durationSignal, notificationsSignal = notificationsSignal
        else {
            return
        }
        
        durationSignal.startWithNext { [weak self] (value) in
            guard let duration = value as? Int else { return }
            self?.timeSaverView.selectedDuration = duration
        }
        
        combineLatest(nameSignal, basisSignal, startTimeSignal, durationSignal, notificationsSignal)
            .startWithNext { [weak self] (name, basis, startTime, duration, notification) in
                self?.selectedName = name as? String
                self?.selectedBasis = basis as? [Int]
                self?.selectedStartTime = startTime as? NSDate
                self?.selectedDuration = duration as? Int
                self?.selectedNotifications = notification as? Bool
            
                self?.moveToNextEditingState()
        }
    }
    
    private func moveToNextEditingState() {
        guard let state = state, nextState = EditingState(rawValue: state.rawValue + 1) else {
            return
        }
        
        machine.state = nextState
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
        state = to
        expandNextCell()
        
        if to == .FullHouse {
            timeSaverView.alpha = 1
        }
    }
    
    private func expandNextCell() {
        guard let
            currentRow = expandedCellIndex?.row,
            currentSection = expandedCellIndex?.section
        else {
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
}

// MARK: - UITableViewDelegate

extension EditActivityVC: UITableViewDelegate {
    
    private enum EditRow: Int {
        case Name = 0
        case Basis
        case StartTime
        case Duration
        case Notifications
        case Saving
        
        func expandableCellType() -> ExpandableCell.Type? {
            switch self {
            case Name: return EditNameCell.self
            case Basis: return EditBasisCell.self
            case StartTime: return EditStartTimeCell.self
            case Duration: return EditDurationCell.self
            case .Notifications: return EditNotificationsCell.self
            default: return nil
            }
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        guard let selectedRow = EditRow(rawValue: indexPath.row) else { return 0 }
        
        if let expandableType = selectedRow.expandableCellType() {
            if indexPath == lastExpandedCellIndex {
                return expandableType.expandedHeight
            } else {
                if let state = state {
                    return expandableType.heightForState(state)
                } else {
                    return expandableType.defaultHeight
                }
            }
        }
        
        return 0
    }
}

// MARK: - UITableViewDataSource
extension EditActivityVC: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Constants.numberOfRows
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row >= EditRow.Notifications.rawValue {
            startTrackingValueChanges()
        }
        
        guard let editRow = EditRow(rawValue: indexPath.row) else { return UITableViewCell() }
        
        switch editRow {
        case .Name: return editNameCellFromTableView(tableView)
        case .Basis: return editBasisCell(fromTableView: tableView)
        case .StartTime: return editStartTimeCell(fromTableView: tableView)
        case .Duration: return editDurationCell(fromTableView: tableView)
        case .Notifications: return editNotificationCell(fromTableView: tableView)
        default: return UITableViewCell()
        }
    }
}


