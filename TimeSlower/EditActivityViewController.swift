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
}

/// Controller that is responsible for editing/entering information about given activity
class EditActivityVC: UIViewController {
    
    private struct Constants {
        static let numberOfRows = 6
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
    
    var userProfile: Profile?
    var activity: Activity?
    
    typealias StateType = EditingState
    private var machine: StateMachine<EditActivityVC>!
    
    var selectedName: String?
    var selectedBasis: [Int]?
    var selectedStartTime: NSDate?
    var selectedDuration: Double?
    var selectedNotifications: Bool?
    var selectedTimeToSave: Double?
    
    var flow: Flow?
    var state: EditingState?
    
    private var lastExpandedCellIndex: NSIndexPath?
    
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
    
    private func setupEvents() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func setupDesign() {
        if activity != nil {
            flow = .Editing
        } else {
            flow = .Creating
            state = .Name
            machine = StateMachine(withState: .Name, delegate: self)
        }
    }
    
    // MARK: - Private Functions
    
    private func resignNameTextfieldAsFirstResponder() {
        guard let
            lastExpandedCellIndex = lastExpandedCellIndex,
            cell = tableView.cellForRowAtIndexPath(lastExpandedCellIndex) as? EditNameCell,
            control = cell.control as? EditActivityNameView
        else { return }
        
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
        bindExpandingBlockToCell(cell)
        
        let nameControl = cell.control as? EditActivityNameView
        nameSignal = nameControl?.rac_valuesForKeyPath("selectedValue", observer: self).toSignalProducer()
        
        return cell
    }

    
    private func editBasisCell(fromTableView tableView: UITableView) -> EditBasisCell {
        let cell: EditBasisCell = tableView.dequeueReusableCell()
        bindExpandingBlockToCell(cell)
        
        let basisControl = cell.control as? EditActivityBasisView
        basisSignal = basisControl?.rac_valuesForKeyPath("selectedValue", observer: self).toSignalProducer()

        return cell
    }
    
    private func bindExpandingBlockToCell(cell: ObservableControlCell) {
        cell.control.rac_signalForControlEvents(.TouchUpInside).toSignalProducer()
            .observeOn(UIScheduler())
            .startWithNext { [weak self] (_) in
                if let cell = cell as? UITableViewCell {
                    self?.expandedCellIndex = self?.tableView.indexPathForCell(cell)
                }
        }
    }
    
    // MARK: - Update state
    
    private func startTrackingValueChanges() {
        guard let nameSignal = nameSignal, basisSignal = basisSignal else { return }
        
        combineLatest(nameSignal, basisSignal)
            .startWithNext { [weak self] (name, basis) in
                self?.selectedName = name as? String
                self?.selectedBasis = basis as? [Int]
                self?.moveToNextEditingState()
        }
    }
    
    private func moveToNextEditingState() {
        guard let state = state, nextState = EditingState(rawValue: state.rawValue + 1) else {
            return
        }
        
        machine.state = nextState
    }
    
    private func expandNextCell() {
        guard let
            currentRow = expandedCellIndex?.row,
            currentSection = expandedCellIndex?.section
            else { return }
        
        let nextRow = currentRow + 1
        if nextRow <= Constants.numberOfRows {
            let nextIndexPath = NSIndexPath(forRow: nextRow, inSection: currentSection)
            expandedCellIndex = nextIndexPath
        } else {
            expandedCellIndex = nil
        }
    }
}

extension EditActivityVC: StateMachineDelegate {
    func shouldTransitionFrom(from: StateType, to: StateType) -> Bool {
        switch (from, to) {
        case (.Name, .Basis):
            return selectedName != nil
        case (.Basis, .StartTime):
            return selectedBasis != nil
        default:
            return false
        }
    }
    
    func didTransitionFrom(from: StateType, to: StateType) {
        state = to
        expandNextCell()
        print("Moved to state: \(state)")
    }
}

// MARK: - UITableViewDelegate

extension EditActivityVC: UITableViewDelegate {
    
    private enum EditRow: Int {
        case Name = 0
        case Basis
        case Duration
        case StartTime
        case Notifications
        case Saving
        
        func expandableCellType() -> ExpandableCell.Type? {
            switch self {
            case Name: return EditNameCell.self
            case Basis: return EditBasisCell.self
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
                return expandableType.defaultHeight
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
        switch indexPath.row {
        case 0: return editNameCellFromTableView(tableView)
        case 1: return editBasisCell(fromTableView: tableView)
        default:
            startTrackingValueChanges()
            return UITableViewCell()
        }
    }
}


class EditDurationCell: UITableViewCell, ObservableControlCell, ExpandableCell {
    @IBOutlet weak var control: UIControl!
    static let expandedHeight: CGFloat = 80
    static let defaultHeight: CGFloat = 50
}

class EditBasisCell: UITableViewCell, ObservableControlCell, ExpandableCell {
    
    @IBOutlet weak var control: UIControl!
    static let screenHeight = UIScreen.mainScreen().bounds.height
    static let expandedHeight: CGFloat = round(0.19 * screenHeight)
    static let defaultHeight: CGFloat = 50

}
