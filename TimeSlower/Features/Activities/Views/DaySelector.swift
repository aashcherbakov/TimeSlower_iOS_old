//
//  DaySelector.swift
//  TimeSlower2
//
//  Created by Oleksandr Shcherbakov on 8/5/15.
//  Copyright (c) 2015 1lastDay. All rights reserved.
//

import UIKit
import TimeSlowerKit

class DaySelector: UIControl {
    
    enum BasisToDisplay: Int {
        case Daily
        case Workdays
        case Weekends
    }
    
    private struct Constants {
        static let defaultButtonWidth: CGFloat = 28
    }
    
    @IBOutlet var dayButtons: [UIButton]!
    
    @IBOutlet private var view: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet private var buttonsWidths: [NSLayoutConstraint]!
    @IBOutlet private var twoLastButtonsWidths: [NSLayoutConstraint]!
    @IBOutlet private var fiveLastButtonsWidths: [NSLayoutConstraint]!
    
    private var daysAvailableToSelect = [String]()

    private(set) var selectedDays = Set<String>()
    private(set) var activeButtons: [UIButton]!
    
    var basis: ActivityBasis! {
        didSet {
            basisToDisplay = BasisToDisplay(rawValue: basis.rawValue)
        }
    }
    
    private var basisToDisplay: BasisToDisplay! {
        didSet {
            setupButtons()
        }
    }
    
    //MARK: - Lifecycle
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupXib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let basis = basisToDisplay {
            layoutButtonWidthForBasis(basis)
        }
    }
    
    //MARK: - Actions
    
    @IBAction private func daySelected(sender: UIButton) {
        updateSelectedListWithButton(sender)
        updateDesignOfButton(sender)
    }
    
    // MARK: - Private Methods
    
    private func setupXib() {
        NSBundle.mainBundle().loadNibNamed("DaySelector", owner: self, options: nil)
        bounds = view.bounds
        addSubview(view)
    }
    
    private func setupButtons() {
        restoreButtonWidths()
        defineAvailableDayNames() // good
        prepareActiveButtons() // good
        setProperButtonsNames() // good
        updateButtonsDesign()
        resetSelectedDays()
        setNeedsLayout()
    }
    
    private func restoreButtonWidths() {
        for width in buttonsWidths {
            width.constant = Constants.defaultButtonWidth
        }
        setNeedsLayout()
    }
    
    private func defineAvailableDayNames() {
        switch basisToDisplay! {
        case .Daily: daysAvailableToSelect = NSDateFormatter().shortWeekdaySymbols as [String]
        case .Workdays: daysAvailableToSelect = ["Mon", "Tue", "Wed", "Thu", "Fri"]
        case .Weekends: daysAvailableToSelect = ["Sat", "Sun"]
        }
    }
    
    private func prepareActiveButtons() {
        activeButtons = dayButtons
        switch basisToDisplay! {
        case .Daily: break
        case .Workdays: activeButtons.removeRange(5...6)
        case .Weekends: activeButtons.removeRange(2...6)
        }
    }
    
    private func setProperButtonsNames() {
        for button in activeButtons {
            button.setTitle(daysAvailableToSelect[button.tag], forState: .Normal)
            button.selected = true
        }
    }
    
    private func updateButtonsDesign() {
        for button in activeButtons {
            updateDesignOfButton(button)
            setupButtonLayer(button)
        }
        setNeedsLayout()
    }
    
    private func updateDesignOfButton(button: UIButton) {
        button.backgroundColor = button.selected ? UIColor.lightGray() : UIColor.clearColor()
    }
    
    private func setupButtonLayer(button: UIButton) {
        button.layer.cornerRadius = Constants.defaultButtonWidth / 2
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.extraLightGray().CGColor
    }
    
    private func resetSelectedDays() {
        selectedDays.removeAll(keepCapacity: false)
        
        for button in activeButtons {
            if let dayName = button.titleLabel?.text {
                selectedDays.insert(dayName)
            }
        }
    }
    
    private func updateSelectedListWithButton(button: UIButton) {
        let selectedDayName = button.titleLabel!.text!
        if button.selected {
            selectedDays.remove(selectedDayName)
        } else {
            selectedDays.insert(selectedDayName)
        }
        
        button.selected = !button.selected
    }
    
    private func layoutButtonWidthForBasis(basis: BasisToDisplay) {
        var widthArray: [NSLayoutConstraint]?
        switch basis {
        case .Daily: break
        case .Workdays: widthArray = twoLastButtonsWidths
        case .Weekends: widthArray = fiveLastButtonsWidths
        }
        
        if let widthToRemove = widthArray {
            for width in widthToRemove {
                width.constant = 0
            }
        }
    }
}
