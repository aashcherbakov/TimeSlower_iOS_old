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
                    if self?.machine.state == .AddName {
                        self?.machine.state = .AddBasis
                    } else {
                        self?.machine.state = .FullHouse
                    }
                }
            }
            .addDisposableTo(disposableBag)
        
        dataView.selectedBasis
            .subscribeNext { [weak self] (basis) -> Void in
                if let basis = basis {
                    self?.basis = basis
                    if self?.startTime != nil {
                        self?.machine.state = .FullHouse
                    } else {
                        self?.machine.state = .AddStartTime
                    }
                }
            }
            .addDisposableTo(disposableBag)
        
        dataView.selectedDuration
            .subscribeNext { [weak self] (duration) -> Void in
                if let duration = duration {
                    self?.duration = duration
                    self?.timeSaver.activityDuration.value = duration
                }
            }
            .addDisposableTo(disposableBag)
        
        dataView.selectedNotifications
            .subscribeNext { [weak self] (enabled) -> Void in
                self?.notificationsOn = enabled
            }
            .addDisposableTo(disposableBag)
        
        timeSaver.timeToSave
            .subscribeNext { [weak self] (minutes) -> Void in
                self?.timeToSave = minutes
            }
            .addDisposableTo(disposableBag)
        
        observeExpandedViewProperties()
    }
    
    private func observeExpandedViewProperties() {
        dataView.expandedName
            .subscribeNext { [weak self] (expanded) -> Void in
                if let expanded = expanded {
                    self?.machine.state = expanded ? .EditName : .FullHouse
                }
            }.addDisposableTo(disposableBag)
        
        dataView.expandedStartTime
            .subscribeNext { [weak self] (expanded) -> Void in
                if let expanded = expanded {
                    self?.machine.state = expanded ? .EditStartTime : .FullHouse
                }
            }.addDisposableTo(disposableBag)
        
        dataView.expandedBasis
            .subscribeNext { [weak self] (expanded) -> Void in
                if let expanded = expanded {
                    self?.machine.state = expanded ? .EditBasis : .FullHouse
                }
            }.addDisposableTo(disposableBag)
    }
    
    private func heightForTableViewInState(state: StateType) -> CGFloat {
        switch state {
        case .NoData: return Constants.defaultCellHeight
        case .AddName, .EditName: return Constants.nameCellExpandedHeight
        case .AddBasis: return Constants.defaultCellHeight + Constants.basisCellExpandedHeight
        case .AddStartTime: return Constants.defaultCellHeight * 2 + Constants.basisCellExpandedHeight
        case .EditStartTime: return Constants.startTimeExpandedHeight + Constants.defaultCellHeight * 2
        case .FullHouse: return Constants.defaultCellHeight * 5
        case .EditBasis: return Constants.defaultCellHeight * 4 + Constants.basisCellExpandedHeight
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
        case (.AddStartTime, .EditStartTime): return true
            
        case (.EditBasis, .EditStartTime): return true
        case (.EditBasis, .EditName): return true
            
        case (.EditStartTime, .EditName): return true
        case (.EditStartTime, .EditBasis): return true
            
        case (.EditName, .FullHouse):return true
        case (.EditBasis, .FullHouse):return true
        case (.EditStartTime, .FullHouse):return true
            
        case (.FullHouse, .EditName): return true
        case (.FullHouse, .EditBasis): return true
        case (.FullHouse, .EditStartTime): return true
            
        default: return false
        }
    }
    
    func didTransitionFrom(from: StateType, to: StateType) {
        print("Transition from \(from) to \(to)")
        dataView.updateDesignForState(to)
        updatedContentSizeHeight.value = heightForTableViewInState(to)
    }
}
