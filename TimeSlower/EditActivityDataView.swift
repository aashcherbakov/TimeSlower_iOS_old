//
//  EditActivityDataView.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 2/20/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation
import RxSwift
import TimeSlowerKit

/** 
 Complex view that contains NameView, BasisView, StartTimeView, DurationView and NotificationsView.
 It is responsible for binding data from views to observable variables and manipulating constraints
 of containing views.
*/
class EditActivityDataView: UIView {
    
    private struct Constants {
        static let defaultCellHeight: CGFloat = 56
        static let nameExpandedHeight: CGFloat = 286
        static let basisExpandedHeight: CGFloat = 128
        static let startTimeExpandedHeight: CGFloat = 218
    }
    
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var editNameView: EditActivityNameView!
    @IBOutlet weak var editBasisView: EditActivityBasisView!
    @IBOutlet weak var editStartTimeView: EditActivityStartTimeView!
    @IBOutlet weak var editDurationView: EditActivityDurationView!
    @IBOutlet weak var editNotificationView: EditActivityNotificationsView!
    
    @IBOutlet private weak var nameViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var basisViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var startTimeViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var durationViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var notificationViewHeightConstraint: NSLayoutConstraint!
    
    // Variables that are set to `true` if given view's height is in expanded state
    var expandedName = Variable<Bool?>(nil)
    var expandedBasis = Variable<Bool?>(nil)
    var expandedStartTime = Variable<Bool?>(nil)
    
    // Variables that represent selected values of given views
    var selectedName = Variable<String>("")
    var selectedBasis = Variable<ActivityBasis?>(nil)
    var selectedStartTime = Variable<NSDate?>(nil)
    var selectedDuration = Variable<Int?>(nil)
    var selectedNotifications = Variable<Bool?>(nil)

    private var disposableBag = DisposeBag()
    
    // MARK: - Overridden Methods
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
       
        setupDesign()
        setupEvents()
    }
    
    func setupWith(activity activity: Activity?) {
        guard let activity = activity else {
            updateDesignForState(.AddName)
            return
        }
        
        editNameView.selectedName.value = activity.name
        editBasisView.selectedBasis.value = activity.activityBasis()
        editStartTimeView.selectedDate.value = activity.timing.startTime
        editDurationView.activityDuration.value = activity.timing.duration.integerValue
        // TODO: assign notifications value
        
        updateDesignForState(.FullHouse)
    }

    /**
     Function used to adjust constraints for given states. Executed with animation duration 0.3
     
     - parameter state: EditActivityState value
     */
    func updateDesignForState(state: EditActivityState) {
        switch state {
        case .NoData: break
        case .AddName, .EditName:
            nameViewHeightConstraint.constant = Constants.nameExpandedHeight
            basisViewHeightConstraint.constant = 0
            startTimeViewHeightConstraint.constant = 0
            durationViewHeightConstraint.constant = 0
            notificationViewHeightConstraint.constant = 0
        case .AddBasis:
            nameViewHeightConstraint.constant = Constants.defaultCellHeight
            basisViewHeightConstraint.constant = Constants.basisExpandedHeight
            startTimeViewHeightConstraint.constant = 0
            durationViewHeightConstraint.constant = 0
            notificationViewHeightConstraint.constant = 0
        case .AddStartTime:
            nameViewHeightConstraint.constant = Constants.defaultCellHeight
            startTimeViewHeightConstraint.constant = Constants.defaultCellHeight
            durationViewHeightConstraint.constant = 0
            notificationViewHeightConstraint.constant = 0
        case .EditStartTime:
            nameViewHeightConstraint.constant = Constants.defaultCellHeight
            basisViewHeightConstraint.constant = Constants.defaultCellHeight
            startTimeViewHeightConstraint.constant = Constants.startTimeExpandedHeight
        case .EditBasis:
            basisViewHeightConstraint.constant = Constants.basisExpandedHeight
            startTimeViewHeightConstraint.constant = Constants.defaultCellHeight
            nameViewHeightConstraint.constant = Constants.defaultCellHeight
        case .FullHouse:
            nameViewHeightConstraint.constant = Constants.defaultCellHeight
            basisViewHeightConstraint.constant = Constants.defaultCellHeight
            startTimeViewHeightConstraint.constant = Constants.defaultCellHeight
            durationViewHeightConstraint.constant = Constants.defaultCellHeight
            notificationViewHeightConstraint.constant = Constants.defaultCellHeight
        }
        
        UIView.animateWithDuration(0.3) { () -> Void in
            self.layoutIfNeeded()
            self.editNameView.layoutSubviews()
        }
    }
    
    // MARK: - Setup Methods
    
    private func setupDesign() {
        NSBundle.mainBundle().loadNibNamed("EditActivityDataView", owner: self, options: nil)
        bounds = view.bounds
        addSubview(view)
    }
    
    private func setupEvents() {
        setupObservationForSelectedValues()
        setupObservationForExpandedProperties()
    }
    
    // MARK: - Private Methods - Bindings
    
    private func setupObservationForSelectedValues() {
        editNameView.selectedName
            .subscribeNext { [weak self] (name) -> Void in
                self?.selectedName.value = name
            }.addDisposableTo(disposableBag)
        
        editBasisView.selectedBasis
            .subscribeNext { [weak self] (basis) -> Void in
                self?.selectedBasis.value = basis
            }.addDisposableTo(disposableBag)
        
        editStartTimeView.selectedDate
            .subscribeNext { [weak self] (date) -> Void in
                self?.selectedStartTime.value = date
            }.addDisposableTo(disposableBag)
        
        editDurationView.activityDuration
            .subscribeNext { [weak self] (duration) -> Void in
                self?.selectedDuration.value = duration
            }.addDisposableTo(disposableBag)
        
        editNotificationView.notificationsOn
            .subscribeNext { [weak self] (enabled) -> Void in
                self?.selectedNotifications.value = enabled
            }.addDisposableTo(disposableBag)
    }
    
    private func setupObservationForExpandedProperties() {
        editStartTimeView.expanded.subscribeNext {
            [weak self] (expanded) -> Void in
                self?.expandedStartTime.value = expanded
            }.addDisposableTo(disposableBag)
        
        editBasisView.expanded.subscribeNext {
            [weak self] (expanded) -> Void in
                self?.expandedBasis.value = expanded
            }.addDisposableTo(disposableBag)
        
        editNameView.expanded.subscribeNext {
            [weak self] (expanded) -> Void in
                self?.expandedName.value = expanded
            }.addDisposableTo(disposableBag)
    }
}