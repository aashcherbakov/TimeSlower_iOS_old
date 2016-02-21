//
//  EditActivityViewModel.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 1/31/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation
import TimeSlowerKit
import RxSwift

/**
 State of ediding an activity
 
 - NoData:            Only name filed is shown with placeholder
 - Name:              Name field and basis field (user entered/entering name)
 - BasisAndStartTime: Name, basis and start time field shown (user selected basis)
 - FullHouse:         All fields are displayed
 */
enum EditActivityState {
    case NoData
    case AddName
    case AddBasis
    case AddStartTime
    case EditName
    case EditBasis
    case EditStartTime
    case FullHouse
}

/// View Model for editing/creating activity
class EditActivityViewModel {
    
    private struct Constants {
        static let defaultCellHeight: CGFloat = 56
        static let nameCellExpandedHeight: CGFloat = 286
        static let basisCellExpandedHeight: CGFloat = 128
        static let startTimeExpandedHeight: CGFloat = 218
    }
    

    
    enum EditActivityCellType: Int {
        case Name = 0
        case Basis
        case StartTime
        case Duration
        case Notification
    }
    
    typealias StateType = EditActivityState
    
    var updatedContentSizeHeight = Variable<CGFloat>(0)
    
    private var machine: StateMachine<EditActivityViewModel>!
    private var disposableBag = DisposeBag()

    private(set) var dataView: EditActivityDataView
    private(set) var timeSaver: TimeSaver
    
    private var name: String?
    private var basis: ActivityBasis?
    private var startTime: NSDate?
    private var notificationsOn: Bool?
    private var duration: Int?
    private var timeToSave: Int?
    private weak var nameTextField: UITextField?
    
    init(withDataView dataView: EditActivityDataView, timeSaver: TimeSaver) {
        self.dataView = dataView
        self.timeSaver = timeSaver
        
        setupEvents()
    }
    
    // MARK: - Setup Methods
    
    private func setupEvents() {
        machine = StateMachine(withState: .NoData, delegate: self)
        updatedContentSizeHeight.value = heightForTableViewInState(machine.state)
        
        if name == nil {
            machine.state = .AddName
        }
        
        dataView.selectedName
            .subscribeNext { [weak self] (name) -> Void in
                if name.characters.count > 0 {
                    self?.name = name
                    self?.machine.state = .AddBasis
                }
            }
            .addDisposableTo(disposableBag)
        
        dataView.selectedBasis.subscribeNext { [weak self] (basis) -> Void in
            if let basis = basis {
                self?.basis = basis
                if self?.startTime != nil {
                    self?.machine.state = .FullHouse
                } else {
                    self?.machine.state = .AddStartTime
                }
            }
        }.addDisposableTo(disposableBag)
        
        
        dataView.expandedName.subscribeNext { [weak self] (expanded) -> Void in
            if let expanded = expanded where expanded == true {
                self?.machine.state = .EditName
            }
        }.addDisposableTo(disposableBag)
        
        dataView.expandedStartTime.subscribeNext { [weak self] (expanded) -> Void in
            if let expanded = expanded where expanded == true {
                self?.machine.state = .EditStartTime
            }
        }.addDisposableTo(disposableBag)
        
        dataView.expandedBasis.subscribeNext { [weak self] (expanded) -> Void in
            if let expanded = expanded where expanded == true {
                self?.machine.state = .EditBasis
            }
        }.addDisposableTo(disposableBag)
        
        
        timeSaver.timeToSave
            .subscribeNext { [weak self] (minutes) -> Void in
                self?.timeToSave = minutes
            }
            .addDisposableTo(disposableBag)
    }
    
//    /**
//     Returns height for given index path due to type of cell and current editing state
//     
//     - parameter indexPath: NSIndexPath from table view delegate
//     
//     - returns: CGFloat for height
//     */
//    func heightForRow(indexPath: NSIndexPath) -> CGFloat {
//        guard let cellType = EditActivityCellType(rawValue: indexPath.row) else { return 0.0 }
//        
//        switch (cellType) {
//        case .Name: return heightForNameCell()
//        case .Basis: return heightForBasisCell()
//        case .StartTime: return heightForStartTimeCell()
//        case .Duration: return heightForDurationCell()
//        case .Notification: return heightForNotificationCell()
//        }
//    }
    
//    /**
//     Method to retrieve specific cell for given index path row
//     
//     - parameter indexPath: NSIndexPath form table view data source
//     
//     - returns: UITableViewCell subclass specific to the row.
//     */
//    func cellForRowAtIndexPath(indexPath: NSIndexPath) -> UITableViewCell {
//        guard let cellType = EditActivityCellType(rawValue: indexPath.row) else { return UITableViewCell() }
//        var cell = UITableViewCell()
//        switch cellType {
//        case .Name: cell = nameCell()
//        case .Basis: cell = basisCell()
//        case .StartTime: cell = startTimeCell()
//        case .Duration: cell = durationCell()
//        case .Notification: cell = notificationCell()
//        }
//        
//        return cell
//    }
    
    // MARK: - Private Methods
    
//    private func nameCell() -> EditActivityNameCell {
//        if let nameCell = tableView.dequeueReusableCellWithIdentifier(EditActivityNameCell.className) as? EditActivityNameCell {
//            nameTextField = nameCell.textFieldView.textField
//            
//            nameCell.selectedName
//                .subscribeNext { [weak self] (name) -> Void in
//                    if name.characters.count > 0 {
//                        self?.name = name
//                        
//                        var nextState = EditActivityState.AddBasis
//                        
//                        if let _ = self?.basis {
//                            nextState = .FullHouse
//                        }
//                        
//                        self?.machine.state = nextState
//                    }
//                }
//                .addDisposableTo(disposableBag)
//            
//            nameCell.textFieldIsEditing
//                .subscribeNext { [weak self] (editing) -> Void in
//                    if editing {
//                        if nameCell.textFieldView.textField.text?.characters.count == 0 {
//                            self?.machine.state = .AddName
//                        } else {
//                            self?.machine.state = .EditName
//                        }
//                    }
//                }
//                .addDisposableTo(disposableBag)
//            
//            return nameCell
//        }
//        return EditActivityNameCell()
//    }
//    
//    private func basisCell() -> EditActivityBasisCell {
//        if let basisCell = tableView.dequeueReusableCellWithIdentifier(EditActivityBasisCell.className) as? EditActivityBasisCell {
//            basisCell.expanded
//                .subscribeNext { [weak self] (expanded) -> Void in
//                    self?.machine.state = expanded ? .AddBasis : .AddStartTime
//                }
//                .addDisposableTo(disposableBag)
//            
//            basisCell.selectedBasis
//                .subscribeNext { [weak self] (basis) -> Void in
//                    self?.basis = basis
//                }
//                .addDisposableTo(disposableBag)
//            
//            basisCell.daySelector.backButton.rx_tap
//                .subscribeNext { [weak self] () -> Void in
//                    self?.machine?.state = .AddBasis
//                }
//                .addDisposableTo(disposableBag)
//            
//            return basisCell
//        }
//        return EditActivityBasisCell()
//    }
//    
//    private func startTimeCell() -> EditActivityStartTimeCell {
//        if let startTimeCell = tableView.dequeueReusableCellWithIdentifier(EditActivityStartTimeCell.className) as? EditActivityStartTimeCell {
//            startTimeCell.selectedDate
//                .subscribeNext { [weak self] (date) -> Void in
//                    self?.startTime = date
//                }
//                .addDisposableTo(disposableBag)
//            
//            startTimeCell.expanded
//                .subscribeNext { [weak self] (expanded) -> Void in
//                    self?.machine.state = expanded ? .AddStartTime : .FullHouse
//                }
//                .addDisposableTo(disposableBag)
//            
//            return startTimeCell
//        }
//        
//        return EditActivityStartTimeCell()
//    }
//    
//    private func durationCell() -> EditActivityDurationCell {
//        if let durationCell = tableView.dequeueReusableCellWithIdentifier(EditActivityDurationCell.className) as? EditActivityDurationCell {
//        
//            durationCell.activityDuration
//                .subscribeNext { [weak self] (duration) -> Void in
//                    if let duration = duration {
//                        self?.duration = duration
//                        self?.timeSaver.activityDuration.value = duration
//                    }
//                }
//                .addDisposableTo(disposableBag)
//            
//            return durationCell
//        }
//        return EditActivityDurationCell()
//    }
//    
//    private func notificationCell() -> EditActivityNotificationCell {
//        if let notificationCell = tableView.dequeueReusableCellWithIdentifier(EditActivityNotificationCell.className) as? EditActivityNotificationCell {
//            
//            notificationCell.notificationsOn
//                .subscribeNext { [weak self] (on) -> Void in
//                    self?.notificationsOn = on
//                }
//                .addDisposableTo(disposableBag)
//            return notificationCell
//        }
//        return EditActivityNotificationCell()
//    }
    
    // MARK: - Private cell height helpers
    
    private func heightForStartTimeCell() -> CGFloat {
        switch machine.state {
        case .AddName, .AddBasis, .NoData: return 0
        case .AddStartTime, .EditStartTime: return Constants.startTimeExpandedHeight
        default: return Constants.defaultCellHeight
        }
    }
    
    private func heightForNameCell() -> CGFloat {
        switch machine.state {
        case .AddName, .EditName: return Constants.nameCellExpandedHeight
        default: return Constants.defaultCellHeight
        }
    }
    
    private func heightForBasisCell() -> CGFloat {
        switch machine.state {
        case .AddName, .EditName: return 0
        case .AddBasis, .EditBasis: return Constants.basisCellExpandedHeight
        default: return Constants.defaultCellHeight
        }
    }
    
    private func heightForDurationCell() -> CGFloat {
        switch machine.state {
        case .FullHouse: return Constants.defaultCellHeight
        default: return 0
        }
    }
    
    private func heightForNotificationCell() -> CGFloat {
        switch machine.state {
        case .FullHouse: return Constants.defaultCellHeight
        default: return 0
        }
    }
    
    private func heightForTableViewInState(state: StateType) -> CGFloat {
        switch state {
        case .NoData: return Constants.defaultCellHeight
        case .AddName, .EditName: return Constants.nameCellExpandedHeight
//        case .Basis: return Constants.defaultCellHeight * 2
//        case .BasisAndDays: return Constants.basisCellExpandedHeight + Constants.defaultCellHeight * 2
//        case .BasisAndStartTime: return Constants.basisCellExpandedHeight + Constants.defaultCellHeight * 2
//        case .FullHouse: return Constants.defaultCellHeight * 5
//        case .StartTime: return Constants.startTimeExpandedHeight + Constants.defaultCellHeight * 2
        default: return 0
        }
    }
}

// MARK: - StateMachineDelegate
extension EditActivityViewModel : StateMachineDelegate {
    
    func shouldTransitionFrom(from: StateType, to: StateType) -> Bool {
        switch (from, to) {
        case (.NoData, .AddName): return true
        case (.AddName, .AddBasis): return true
        case (.AddBasis, .AddStartTime): return true
        case (.AddStartTime, .FullHouse): return true
        case (.AddStartTime, .EditStartTime): return true
//        case (.Name, .Basis): return true
//        case (.Basis, .BasisAndDays): return true
//        case (.Basis, .Name): return true
//        case (.BasisAndDays, .Name): return true
//        case (.BasisAndDays, .BasisAndStartTime): return true
//        case (.BasisAndDays, .StartTime): return true
//        case (.BasisAndStartTime, .BasisAndDays): return true
//        case (.BasisAndStartTime, .StartTime): return true
//        case (.BasisAndStartTime, .Name): return true
//        case (.StartTime, .BasisAndStartTime): return true
//        case (.StartTime, .BasisAndDays): return true
//        case (.StartTime, .FullHouse):return true
//        case (.FullHouse, .StartTime): return true
//        case (.FullHouse, .Name): return true
//        case (.FullHouse, .BasisAndDays): return true
//        case (.BasisAndStartTime, .FullHouse): return true
        default: return false
        }
    }
    
    func didTransitionFrom(from: StateType, to: StateType) {
        print("Transition from \(from) to \(to)")
        dataView.updateDesignForState(to)
//        tableView.beginUpdates()
//        tableView.endUpdates()
//        
//        updatedContentSizeHeight.value = heightForTableViewInState(machine.state)
//        if to == .EditName || to == .AddName {
//            tableView.becomeFirstResponder()
//            nameTextField?.becomeFirstResponder()
//        }
    }
}
