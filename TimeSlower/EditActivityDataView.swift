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

class EditActivityDataView: UIView {
    
    private struct Constants {
        static let defaultCellHeight: CGFloat = 56
        static let nameExpandedHeight: CGFloat = 286
        static let basisExpandedHeight: CGFloat = 128
        static let startTimeExpandedHeight: CGFloat = 218
    }
    
    @IBOutlet var view: UIView!
    @IBOutlet weak var editNameView: EditActivityNameView!
    @IBOutlet weak var editBasisView: EditActivityBasisView!
    @IBOutlet weak var editStartTimeView: EditActivityStartTimeView!
    
    @IBOutlet weak var nameViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var basisViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var startTimeViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var durationViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var notificationViewHeightConstraint: NSLayoutConstraint!
    
    var expandedName = Variable<Bool?>(nil)
    var expandedBasis = Variable<Bool?>(nil)
    var expandedStartTime = Variable<Bool?>(nil)
    
    var selectedName = Variable<String>("")
    var selectedBasis = Variable<ActivityBasis?>(nil)
    var selectedStartTime = Variable<NSDate?>(nil)
    var selectedDuration = Variable<Int?>(nil)
    var selectedNotifications = Variable<Bool?>(nil)

    private var disposableBag = DisposeBag()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupXib()
        
        setupEvents()
    }

    func setupEvents() {
        editNameView.selectedName.subscribeNext {
                [weak self] (name) -> Void in
                self?.selectedName.value = name
            }.addDisposableTo(disposableBag)
        
        editBasisView.selectedBasis.subscribeNext {
                [weak self] (basis) -> Void in
                self?.selectedBasis.value = basis
            }.addDisposableTo(disposableBag)
        
        editStartTimeView.selectedDate.subscribeNext {
                [weak self] (date) -> Void in
                self?.selectedStartTime.value = date
            }.addDisposableTo(disposableBag)
        
        setupObservationForExpandedProperties()
    }
    
    func setupObservationForExpandedProperties() {
        editStartTimeView.expanded.subscribeNext {
            [weak self] (expanded) -> Void in
                self?.expandedStartTime.value = expanded
            }.addDisposableTo(disposableBag)

        editBasisView.expanded.subscribeNext {
            [weak self] (expanded) -> Void in
                self?.expandedBasis.value = expanded
            }.addDisposableTo(disposableBag)
        
        editNameView.textFieldIsEditing.subscribeNext {
            [weak self] (expanded) -> Void in
                self?.expandedName.value = expanded
            }.addDisposableTo(disposableBag)
    }
    
    func setupXib() {
        NSBundle.mainBundle().loadNibNamed("EditActivityDataView", owner: self, options: nil)
        bounds = view.bounds
        addSubview(view)
        
        updateDesignForState(.AddName)
    }
    
    func updateDesignForState(state: EditActivityState) {
        switch state {
        case .NoData: break
        case .AddName:
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
        case .FullHouse:
            nameViewHeightConstraint.constant = Constants.defaultCellHeight
            basisViewHeightConstraint.constant = Constants.defaultCellHeight
            startTimeViewHeightConstraint.constant = Constants.defaultCellHeight
            durationViewHeightConstraint.constant = Constants.defaultCellHeight
            notificationViewHeightConstraint.constant = Constants.defaultCellHeight
        default: return
        }
        
        UIView.animateWithDuration(0.3) { () -> Void in
            self.layoutIfNeeded()
            self.editNameView.layoutSubviews()
        }
    }
}