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

/**
 *  Struct that holds data for creating/editing activity
 */
struct ActivityBlankModel {
    var name: String
    var basis: ActivityBasis
    var startTime: NSDate
    var duration: Int
    var notificationsOn: Bool
    var timeToSave: Int
    
    init(withName name: String, basis: ActivityBasis, startTime: NSDate, duration: Int, notificationsOn: Bool, timeToSave: Int) {
        self.name = name
        self.basis = basis
        self.startTime = startTime
        self.duration = duration
        self.notificationsOn = notificationsOn
        self.timeToSave = timeToSave
    }
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
    
    /// Height of all views of EditActivityDataView combined. Used to update top white view height
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
    private var activity: Activity?
    
    init(withDataView dataView: EditActivityDataView, timeSaver: TimeSaver, activity: Activity?) {
        self.dataView = dataView
        self.timeSaver = timeSaver
        self.activity = activity
        
        setupData()
        setupDesign()
        setupEvents()
    }
    
    // MARK: - Internal Methods
    
    /**
    Method do find out if any views are in expanded state (are editing)
    
    - returns: true if any view is being edited now
    */
    func isEditingAnyField() -> Bool {
        return machine.state != .FullHouse
    }
    
    /**
     Sets editing state to .FullHouse - all views are of the same height, none is expanded
     */
    func resetEditingState() {
        if machine.state != .AddName && machine.state != .AddBasis && machine.state != .AddStartTime {
            machine.state = .FullHouse
        }
    }
    
    /**
     Method to determine if data entered in both EditActivityDataView and TimeSaver are valid
     
     - returns: ActivityBlankModel if data is entered or String with message which data is missing
     */
    func isDataEntered() -> (model: ActivityBlankModel?, missingData: String?) {
        if let name = name, basis = basis, startTime = startTime,
            notificationsOn = notificationsOn, duration = duration,
            timeToSave = timeToSave where name.characters.count > 0 {
                let model = ActivityBlankModel(
                    withName: name,
                    basis: basis,
                    startTime: startTime,
                    duration: duration,
                    notificationsOn: notificationsOn,
                    timeToSave: timeToSave)
                return (model, nil)
        } else {
            return (nil, missingDataString())
        }
    }
    
    // MARK: - Setup Methods
    
    private func setupData() {
        if let activity = activity {
            updatePropertiesForActivity(activity)
            dataView.setupWith(activity: activity)
            timeSaver.timeToSave.value = activity.timing.timeToSave.integerValue
        }
    }
    
    private func updatePropertiesForActivity(activity: Activity) {
        name = activity.name
        basis = activity.activityBasis()
        startTime = activity.timing.startTime
        duration = activity.timing.duration.integerValue
        timeToSave = activity.timing.timeToSave.integerValue
    }
    
    private func setupDesign() {
        let initialState: EditActivityState = activity == nil ? .NoData : .FullHouse
        machine = StateMachine(withState: initialState, delegate: self)
        updatedContentSizeHeight.value = heightForTableViewInState(machine.state)
        
        if name == nil {
            machine.state = .AddName
        }
        
        setupTimeSaverVisability(forState: machine.state)
    }
    
    private func setupEvents() {
        observeSelectedName()
        observeSelectedBasis()
        observeSelectedStartTime()
        observeSelectedDuration()
        observeSelectedNotification()
        observeTimeSaverValue()
        observeExpandedViewProperties()
    }
    
    // MARK: - Private Methods
    
    private func observeSelectedName() {
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
            }.addDisposableTo(disposableBag)
    }
    
    private func observeSelectedBasis() {
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
            }.addDisposableTo(disposableBag)
    }
    
    private func observeSelectedStartTime() {
        dataView.selectedStartTime
            .subscribeNext { [weak self] (date) -> Void in
                if let date = date {
                    self?.startTime = date
                }
            }.addDisposableTo(disposableBag)
    }

    private func observeSelectedDuration() {
        dataView.selectedDuration
            .subscribeNext { [weak self] (duration) -> Void in
                if let duration = duration {
                    self?.duration = duration
                    self?.timeSaver.activityDuration.value = duration
                }
            }.addDisposableTo(disposableBag)
    }
    
    private func observeSelectedNotification() {
        dataView.selectedNotifications
            .subscribeNext { [weak self] (enabled) -> Void in
                self?.notificationsOn = enabled
            }.addDisposableTo(disposableBag)

    }
    
    private func observeTimeSaverValue() {
        timeSaver.timeToSave
            .subscribeNext { [weak self] (minutes) -> Void in
                self?.timeToSave = minutes
            }.addDisposableTo(disposableBag)
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
    
    private func setupTimeSaverVisability(forState state: StateType) {
        let shouldNotShow = state == .NoData || state == .AddBasis || state == .AddName || state == .AddStartTime
        timeSaver.alpha = shouldNotShow ? 0.0 : 1.0
    }
    
    private func missingDataString() -> String? {
        if name == nil { return "Name is missing!" }
        if basis == nil { return "Please, select basis to continue" }
        if startTime == nil { return "You forgot to enter start time" }
        return nil
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
        setupTimeSaverVisability(forState: to)
    }
}
