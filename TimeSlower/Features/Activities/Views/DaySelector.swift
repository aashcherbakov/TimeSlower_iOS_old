//
//  DaySelector.swift
//  TimeSlower2
//
//  Created by Oleksandr Shcherbakov on 8/5/15.
//  Copyright (c) 2015 1lastDay. All rights reserved.
//

import UIKit
import TimeSlowerKit

/// UIControl subclass that alows to pick days of activity basis
class DaySelector: UIControl {
    
    private struct Constants {
        static let defaultButtonWidth: CGFloat = 28
    }
    
    @IBOutlet var dayButtons: [UIButton]!
    @IBOutlet private var view: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet private var buttonsWidths: [NSLayoutConstraint]!
    @IBOutlet private var twoLastButtonsWidths: [NSLayoutConstraint]!
    @IBOutlet private var fiveLastButtonsWidths: [NSLayoutConstraint]!
    
    private var daysAvailableToSelect: [Weekday] = Weekday.weekdaysForBasis(.Daily)
    
    /// Set of days in format "Mon" "Fri" etc
    private(set) var selectedDays = Set<Int>()
    
    /// Basis that comes out of selected days
    var selectedBasis: Basis = .Random {
        didSet {
            setupButtonsForBasis()
        }
    }
    
    // MARK: - Overridden Methods
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupDesign()
    }

    func displayValue(value: [Int]) {
        selectedDays = Set(value)
        setupButtonsForSelectedDays(value)
        updateButtonsDesign()
    }
    
    // MARK: - Setup Methods
    
    private func setupDesign() {
        setupXib()
        setupInitialButtonsDesign()
        setupButtonsForBasis()
    }
    
    private func setupXib() {
        NSBundle.mainBundle().loadNibNamed("DaySelector", owner: self, options: nil)
        bounds = view.bounds
        addSubview(view)
    }
    
    private func setupInitialButtonsDesign() {
        for button in dayButtons {
            button.backgroundColor = UIColor.clearColor()
            button.setTitleColor(UIColor.lightGray(), forState: .Normal)
            button.setTitleColor(UIColor.purpleRed(), forState: .Selected)
        }
    }
    
    //MARK: - Actions
    
    @IBAction private func daySelected(sender: UIButton) {
        updateSelectedListWithButton(sender)
        updateDesignOfButton(sender)
    }
    
    // MARK: - Private Methods
    
    private func setupButtonsForBasis() {
        setProperButtonsNames()
        updateButtonsDesign()
        resetSelectedDays()
        setNeedsLayout()
    }
    
    private func setProperButtonsNames() {        
        let daysForBasis = Weekday.weekdaysForBasis(selectedBasis)
        
        for button in dayButtons {
            let weekday = daysAvailableToSelect[button.tag]
            button.setTitle(weekday.shortName, forState: .Normal)
            
            if selectedBasis != .Random {
                button.selected = daysForBasis.contains(weekday)
            }
        }
    }
    
    private func updateButtonsDesign() {
        for button in dayButtons {
            updateDesignOfButton(button)
            setupButtonLayer(button)
        }
        setNeedsLayout()
    }
    
    private func updateDesignOfButton(button: UIButton) {
        let color = button.selected ? UIColor.purpleRed().CGColor : UIColor.lightGray().CGColor
        button.layer.borderColor = color
    }
    
    private func setupButtonLayer(button: UIButton) {
        button.layer.cornerRadius = Constants.defaultButtonWidth / 2
        button.layer.borderWidth = 1
    }
    
    private func resetSelectedDays() {
        selectedDays.removeAll(keepCapacity: false)

        for button in dayButtons {
            if button.selected {
                selectedDays.insert(daysAvailableToSelect[button.tag].rawValue)
            }
        }
    }
    
    private func updateSelectedListWithButton(button: UIButton) {
        let selectedWeekday = daysAvailableToSelect[button.tag]
        if button.selected {
            selectedDays.remove(selectedWeekday.rawValue)
        } else {
            selectedDays.insert(selectedWeekday.rawValue)
        }
        
        button.selected = !button.selected
        let weekdays = weekdaysFromSelectedDays(selectedDays)
        selectedBasis = Basis.basisFromWeekdays(weekdays)
        sendActionsForControlEvents(.ValueChanged)
    }
    
    private func setupButtonsForSelectedDays(days: [Int]) {
        let weekdays = Set(weekdaysFromSelectedDays(Set(days)))
        let selectedDayNames = weekdays.map { (weekday) -> String in
            return weekday.shortName
        }
        
        for button in dayButtons {
            if let title = button.titleLabel?.text where selectedDayNames.contains(title) {
                button.selected = true
            }
        }
    }
    
    private func weekdaysFromSelectedDays(days: Set<Int>) -> [Weekday] {
        var weekdays: [Weekday] = []
        for day in days {
            if let weekday = Weekday(rawValue: day) {
                weekdays.append(weekday)
            }
        }
        return weekdays
    }
}
