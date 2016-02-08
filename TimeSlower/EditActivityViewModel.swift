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

/// View Model for editing/creating activity
class EditActivityViewModel {
    
    private struct Constants {
        static let defaultCellHeight: CGFloat = 56
        static let nameCellExpandedHeight: CGFloat = 276
        static let basisCellExpandedHeight: CGFloat = 112
    }
    
    /**
     State of ediding an activity
     
     - NoData:            Only name filed is shown with placeholder
     - Name:              Name field and basis field (user entered/entering name)
     - BasisAndStartTime: Name, basis and start time field shown (user selected basis)
     - FullHouse:         All fields are displayed
     */
    enum EditActivityState {
        case NoData
        case Name
        case Basis
        case BasisAndDays
        case BasisAndStartTime
        case FullHouse
    }
    
    enum EditActivityCellType: Int {
        case Name = 0
        case Basis
        case StartTime
        case Duration
        case Notification
    }
    
    typealias StateType = EditActivityState
    private var machine: StateMachine<EditActivityViewModel>!
    private var disposableBag = DisposeBag()

    private(set) var tableView: UITableView
    
    private var name: String?
    private var basis: String?
    private var startTime: NSDate?
    private var notificationsOn: Bool?
    private var duration: Double?
    private var timeToSave: Double?
    
    init(withTableView tableView: UITableView) {
        self.tableView = tableView
        machine = StateMachine(withState: .Name, delegate: self)
    }
    
    func heightForRow(indexPath: NSIndexPath) -> CGFloat {
        guard let cellType = EditActivityCellType(rawValue: indexPath.row) else { return 0.0 }
        
        switch (cellType) {
        case .Name: return heightForNameCell()
        case .Basis: return heightForBasisCell()
        default: return 0
        }
    }
    
    private func heightForNameCell() -> CGFloat {
        switch machine.state {
        case .Name: return Constants.nameCellExpandedHeight
        default: return Constants.defaultCellHeight
        }
    }
    
    private func heightForBasisCell() -> CGFloat {
        switch machine.state {
        case .Name: return 0
        case .BasisAndDays: return Constants.basisCellExpandedHeight
        default: return Constants.defaultCellHeight
        }
    }
    
    func cellForRowAtIndexPath(indexPath: NSIndexPath) -> UITableViewCell {
        guard let cellType = EditActivityCellType(rawValue: indexPath.row) else { return UITableViewCell() }
        var cell = UITableViewCell()
        switch cellType {
        case .Name: cell = nameCell()
        case .Basis: cell = basisCell()
        default: break
        }
        
        return cell
    }
    
    // MARK: - Private Methods
    
    private func nameCell() -> EditActivityNameCell {
        if let nameCell = tableView.dequeueReusableCellWithIdentifier(EditActivityNameCell.className) as? EditActivityNameCell {
            
            nameCell.selectedName
                .subscribeNext { [weak self] (name) -> Void in
                    if name.characters.count > 0 {
                        self?.name = name
                        self?.machine.state = .Basis
                    }
                }.addDisposableTo(disposableBag)
            
            nameCell.textFieldIsEditing
                .subscribeNext { (editing) -> Void in
                    if editing {
                        self.machine.state = .Name
                    }
                }.addDisposableTo(disposableBag)
            
            return nameCell
        }
        return EditActivityNameCell()
    }
    
    private func basisCell() -> EditActivityBasisCell {
        if let basisCell = tableView.dequeueReusableCellWithIdentifier(EditActivityBasisCell.className) as? EditActivityBasisCell {
            basisCell.basisSelector.selectedSegmentIndex
                .subscribeNext { [weak self] (index) -> Void in
                    self?.machine?.state = .BasisAndDays
                }
                .addDisposableTo(disposableBag)
            
            basisCell.daySelector.backButton.rx_tap
                .subscribeNext { [weak self] () -> Void in
                    self?.machine?.state = .BasisAndStartTime
                }
                .addDisposableTo(disposableBag)
            
            return basisCell
        }
        return EditActivityBasisCell()
    }
}

// MARK: - StateMachineDelegate
extension EditActivityViewModel : StateMachineDelegate {
    
    func shouldTransitionFrom(from: StateType, to: StateType) -> Bool {
        switch (from, to) {
        case (.NoData, .Name): return true
        case (.Name, .Basis): return true
        case (.Basis, .BasisAndDays): return true
        case (.Basis, .Name): return true
        case (.BasisAndDays, .Name): return true
        case (.BasisAndDays, .BasisAndStartTime): return true
        case (.BasisAndStartTime, .BasisAndDays): return true
        case (.BasisAndStartTime, .Name): return true
        case (.BasisAndStartTime, .FullHouse): return true
        default: return false
        }
    }
    
    func didTransitionFrom(from: StateType, to: StateType) {
        tableView.beginUpdates()
        tableView.endUpdates()
    }
}
