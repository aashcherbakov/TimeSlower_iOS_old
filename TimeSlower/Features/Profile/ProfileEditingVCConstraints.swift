//
//  ProfileEditingVCConstraints.swift
//  TimeSlower2
//
//  Created by Aleksander Shcherbakov on 5/11/15.
//  Copyright (c) 2015 1lastDay. All rights reserved.
//

import UIKit

class ProfileEditingVCConstraints: UIViewController {

    enum EditingState: Int {
        case Default
        case Name
        case Birthday
        case Country
    }
    
    struct Constants {
        // to height excluding navigation bar
        static let avatarHeightFactor: CGFloat = 0.18
        static let genderViewFactor: CGFloat = 0.18
        static let propertyCellViewFactor: CGFloat = 0.11
        static let topPropertyOffsetFactor: CGFloat = 0.07
        static let buttonDownOffsetFactor: CGFloat = 0.04
        
        // to view total height
        static let backgroundImageFactor: CGFloat = 0.46
        
        static let standardPickerViewHeigth: CGFloat = 192
        static let horizontalOffset: CGFloat = 0.12 // to width
    }
    
    //MARK: Height constraints
    @IBOutlet weak var backgroundImageHeight: NSLayoutConstraint!
    @IBOutlet weak var genderViewHeight: NSLayoutConstraint!
    @IBOutlet weak var propertiesView: UIView!
    @IBOutlet weak var distanceFromNavBar: NSLayoutConstraint!
    @IBOutlet weak var buttonDownOffset: NSLayoutConstraint!
    @IBOutlet weak var avatarViewHeight: NSLayoutConstraint!
    
    //MARK: Labels outlets // for fonts sizes
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var avatarInnerView: UIView!
    @IBOutlet weak var avatarFrameView: UIView!

    var currentEditingState: EditingState = .Default { didSet { animateConstraintChanges() } }
    var defaultConstraintsSet = false
    let standardCellHeight = kUsableViewHeight * Constants.propertyCellViewFactor
    let standardPropertyOffset = kUsableViewHeight * Constants.topPropertyOffsetFactor
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBarHidden = false

    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        if !defaultConstraintsSet {
            setDefaultConstraints()
        }
        
        switch currentEditingState {
        case .Default: setConstraintsForDefaultEditingState()
        case .Name: setConstraintsForEditingName()
        case .Birthday: setConstraintsForEditingBirthday()
        case .Country: setConstraintsForEditingCountry()
        }
    }
    
    func animateConstraintChanges() {
        UIView.animateWithDuration(0.3) {
            [unowned self]() -> () in
            self.updateViewConstraints()
            self.view.layoutIfNeeded()
        }
    }

    @IBAction func propertisViewTapped(sender: UITapGestureRecognizer) {
//        let tapPoint = sender.locationInView(propertiesView)
//        let tapedView = propertiesView.hitTest(tapPoint, withEvent: nil)
//        
//        if let view = tapedView {
//            if view.tag == 2 {
//                currentEditingState = (currentEditingState != .Birthday) ? .Birthday : .Default
//            } else if view.tag == 3 {
//                currentEditingState = (currentEditingState != .Country) ? .Country : .Default
//            } 
//        }
    }
    
    func setDefaultConstraints() {
//        topPropertyOffset.constant = standardPropertyOffset
        genderViewHeight.constant = kUsableViewHeight * Constants.genderViewFactor
        backgroundImageHeight.constant = UIScreen.mainScreen().bounds.height * Constants.backgroundImageFactor
        
//        for propertieHeight in [nameViewHeight, datePickerViewHeight, countryViewHeight] {
//            propertieHeight.constant = kUsableViewHeight * Constants.propertyCellViewFactor
//        }
//        
//        for pickerHeight in [datePickerViewHeight, countryPickerViewHeight] {
//            pickerHeight.constant = 0.0
//        }
//        
//        for offset in horizontalOffset {
//            offset.constant = kUsableViewWidth * Constants.horizontalOffset
//        }
        
        defaultConstraintsSet = true
        setCircleFormToAvatarImageView()
    }
    
    func setCircleFormToAvatarImageView() {
        avatarFrameView.layer.cornerRadius = avatarViewHeight.constant / 2
        avatarFrameView.layer.borderWidth = 1.0
        avatarFrameView.layer.borderColor = UIColor.purpleRed().CGColor
        avatarInnerView.layer.cornerRadius = avatarInnerView.bounds.height / 2
    }
    
    func setAllPropertyConstraintsToZero() {
//        topPropertyOffset.constant = 0.0
//        nameViewHeight.constant = 0.0
//        birthdayViewHeight.constant = 0.0
//        countryViewHeight.constant = 0.0
//        datePickerViewHeight.constant = 0.0
//        countryPickerViewHeight.constant = 0.0
        
    }
    
    func setConstraintsForEditingName() {
        setAllPropertyConstraintsToZero()
//        nameViewHeight.constant = standardCellHeight
    }
    
    func setConstraintsForEditingBirthday() {
        setAllPropertyConstraintsToZero()
//        birthdayViewHeight.constant = standardCellHeight
//        datePickerViewHeight.constant = Constants.standardPickerViewHeigth
    }
    
    func setConstraintsForEditingCountry() {
        setAllPropertyConstraintsToZero()
//        countryViewHeight.constant = standardCellHeight
//        countryPickerViewHeight.constant = Constants.standardPickerViewHeigth
    }
    

    func setConstraintsForDefaultEditingState() {
//        for constraint in [nameViewHeight, birthdayViewHeight, countryViewHeight] {
//            constraint.constant = standardCellHeight
//        }
//        topPropertyOffset.constant = standardPropertyOffset
//        datePickerViewHeight.constant = 0.0
//        countryPickerViewHeight.constant = 0.0
    }
}


