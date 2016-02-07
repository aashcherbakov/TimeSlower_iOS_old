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
        static let defaultEditingCellHeight: CGFloat = 56
        static let nameCellExtpandedHeight: CGFloat = 276
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
    
    private var name: String? {
        didSet {
            print("Name is set to \(name)")
        }
    }
    private var basis: String?
    private var startTime: NSDate?
    private var notificationsOn: Bool?
    private var duration: Double?
    private var timeToSave: Double?
    
    init(withTableView tableView: UITableView) {
        self.tableView = tableView
        machine = StateMachine(withState: .Name, delegate: self)
    }
    
    func numberOfRows() -> Int {
        switch machine.state {
        case .NoData: return 1
        case .Name: return 2
        case .BasisAndStartTime: return 3
        case .FullHouse: return 5
        }
    }
    
    func heightForRow(indexPath: NSIndexPath) -> CGFloat {
        guard let cellType = EditActivityCellType(rawValue: indexPath.row) else { return 0.0 }
        
        switch (cellType, machine.state) {
        case (.Name, .Name):
            return Constants.nameCellExtpandedHeight
        case (.StartTime, .BasisAndStartTime):
            return Constants.nameCellExtpandedHeight
        default: return Constants.defaultEditingCellHeight
        }
    }
    
    func cellForRowAtIndexPath(indexPath: NSIndexPath) -> UITableViewCell {
        guard let cellType = EditActivityCellType(rawValue: indexPath.row) else { return UITableViewCell() }
        var cell = UITableViewCell()
        switch cellType {
        case .Name:
            if let nameCell = tableView.dequeueReusableCellWithIdentifier(EditActivityNameCell.className) as? EditActivityNameCell {
                nameCell.selectedName
                    .subscribeNext { [weak self] (name) -> Void in
                        if name.characters.count > 0 {
                            self?.name = name
                            self?.machine.state = .BasisAndStartTime
                        }
                    }
                    .addDisposableTo(disposableBag)
                
                nameCell.textFieldIsEditing
                    .subscribeNext { (editing) -> Void in
                        if editing {
                            self.machine.state = .Name
                        }
                    }
                    .addDisposableTo(disposableBag)
                
                cell = nameCell
                
            }
        default: break
        }
        
        return cell
    }
    
    // MARK: - Private functions
}

// MARK: - StateMachineDelegate
extension EditActivityViewModel : StateMachineDelegate {
    
    func shouldTransitionFrom(from: StateType, to: StateType) -> Bool {
        switch (from, to) {
        case (.NoData, .Name): return true
        case (.Name, .BasisAndStartTime): return true
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
