//
//  EditActivityVCConstraints.swift
//  TimeSlower2
//
//  Created by Aleksander Shcherbakov on 5/7/15.
//  Copyright (c) 2015 1lastDay. All rights reserved.
//

import UIKit
import TimeSlowerKit


class EditActivityVCConstraints: UIViewController {
    
    enum EditingState: Int {
        case Default = 0
        case NameOnly
        case BasisDetail
        case StartTime
    }
    struct Constants {
        static let topWhiteViewFactor: CGFloat = 0.58
        static let cellHeightFactor: CGFloat = 0.1
        static let timeSaverViewFactor: CGFloat = 0.26
        static let offsetFromCellsToDownWhite: CGFloat = 30
        static let horizontalOffsetFactor: CGFloat = 0.11
        static let defaultPickerHeightFactor: CGFloat = 0.43
    }

    @IBOutlet weak var timeSaverViewHeignt: NSLayoutConstraint!
    @IBOutlet weak var buttonHeight: NSLayoutConstraint!
    @IBOutlet weak var topWhiteViewHeight: NSLayoutConstraint!
    
    
    //MARK: - Offsets
    @IBOutlet weak var leftOffset: NSLayoutConstraint!
    @IBOutlet weak var rightOffset: NSLayoutConstraint!
    @IBOutlet weak var buttonDownOffset: NSLayoutConstraint!

    
//    var activity: Activity?
    var editingState: EditingState = .Default { didSet { animateConstraintChanges() } }
    var defaultConstraintsSet = false

    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        if activity == nil {
//            editingState = .NameOnly
//        }
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        if !defaultConstraintsSet {
            setDefaultConstraints()
        }
        
        switch editingState {
        case .Default: setConstraintsForDefaultState()
        case .NameOnly: setConstraintsForNameOnlyState()
        case .BasisDetail: setConstraintsForBasisDetail()
        case .StartTime: setConstraintsForStartTime()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func animateConstraintChanges() {
        UIView.animateWithDuration(0.2) {
            [weak self]() -> () in
            self?.updateViewConstraints()
            self?.view.layoutIfNeeded()
        }
    }
    
    func setDefaultConstraints() {
        buttonDownOffset.constant = kUsableViewHeight * LayoutConstants.buttonDownOffset
        buttonHeight.constant = kUsableViewHeight * LayoutConstants.buttonHeightScale
//        rightOffset.constant = kUsableViewWidth * Constants.horizontalOffsetFactor
//        leftOffset.constant = kUsableViewWidth * Constants.horizontalOffsetFactor
        
        defaultConstraintsSet = true
    }
    
    
    func setConstraintsForDefaultState() {
        // hide datePicker and basisPickerDetail
//        datePickerViewHeight.constant = 0.0
//        basisDaysViewHeight.constant = 0.0
//        
        // big views
//        topWhiteViewHeight.constant = kUsableViewHeight * Constants.topWhiteViewFactor
        timeSaverViewHeignt.constant = kUsableViewHeight * Constants.timeSaverViewFactor

        // all other equal
//        for constraint in [nameViewHeight, basisViewHeight,
//            startTimeViewHeight, durationViewHeight, notificationViewHeight] {
//            constraint.constant = kUsableViewHeight * Constants.cellHeightFactor
//        }
    }
    
    func setConstraintsForNameOnlyState() {
        
//        for constraint in [basisViewHeight, basisDaysViewHeight, startTimeViewHeight, datePickerViewHeight, durationViewHeight, notificationViewHeight] {
//            constraint.constant = 0
//        }
//        
//        defaultPickerHeight.constant = kUsableViewHeight * Constants.defaultPickerHeightFactor
//        topWhiteViewHeight.constant = defaultPickerHeight.constant + nameViewHeight.constant
        
    }
    
    func setConstraintsForBasisDetail() {
//        basisViewHeight.constant = 0.0
//        basisDaysViewHeight.constant = kUsableViewHeight * Constants.cellHeightFactor
    }
    
    func setConstraintsForStartTime() {
//        for constraint in [basisViewHeight, basisDaysViewHeight, durationViewHeight, notificationViewHeight] {
//            constraint.constant = 0.0
//        }
//        
//        datePickerViewHeight.constant = 182
//        topWhiteViewHeight.constant = nameViewHeight.constant + startTimeViewHeight.constant + datePickerViewHeight.constant + Constants.offsetFromCellsToDownWhite
    }
}


