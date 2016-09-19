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
    
    fileprivate struct Constants {
        static let defaultButtonWidth: CGFloat = 28
    }
    
    @IBOutlet var dayButtons: [UIButton]!
    @IBOutlet fileprivate var view: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet fileprivate var buttonsWidths: [NSLayoutConstraint]!
    @IBOutlet fileprivate var twoLastButtonsWidths: [NSLayoutConstraint]!
    @IBOutlet fileprivate var fiveLastButtonsWidths: [NSLayoutConstraint]!
    
    fileprivate var daysAvailableToSelect: [Weekday] = Weekday.weekdaysForBasis(.daily)
    
    /// Set of days in format "Mon" "Fri" etc
    fileprivate(set) var selectedDays = Set<Int>()
    
    /// Basis that comes out of selected days
    var selectedBasis: Basis = .random {
        didSet {
            setupButtonsForBasis()
        }
    }
    
    // MARK: - Overridden Methods
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupDesign()
    }

    func displayValue(_ value: [Int]) {
        selectedDays = Set(value)
        setupButtonsForSelectedDays(value)
        updateButtonsDesign()
    }
    
    // MARK: - Setup Methods
    
    fileprivate func setupDesign() {
        setupXib()
        setupInitialButtonsDesign()
        setupButtonsForBasis()
    }
    
    fileprivate func setupXib() {
        Bundle.main.loadNibNamed("DaySelector", owner: self, options: nil)
        bounds = view.bounds
        addSubview(view)
    }
    
    fileprivate func setupInitialButtonsDesign() {
        for button in dayButtons {
            button.backgroundColor = UIColor.clear
            button.setTitleColor(UIColor.lightGray(), for: UIControlState())
            button.setTitleColor(UIColor.purpleRed(), for: .selected)
        }
    }
    
    //MARK: - Actions
    
    @IBAction fileprivate func daySelected(_ sender: UIButton) {
        updateSelectedListWithButton(sender)
        updateDesignOfButton(sender)
    }
    
    // MARK: - Private Methods
    
    fileprivate func setupButtonsForBasis() {
        setProperButtonsNames()
        updateButtonsDesign()
        resetSelectedDays()
        setNeedsLayout()
    }
    
    fileprivate func setProperButtonsNames() {        
        let daysForBasis = Weekday.weekdaysForBasis(selectedBasis)
        
        for button in dayButtons {
            let weekday = daysAvailableToSelect[button.tag]
            button.setTitle(weekday.shortName, for: UIControlState())
            
            if selectedBasis != .random {
                button.isSelected = daysForBasis.contains(weekday)
            }
        }
    }
    
    fileprivate func updateButtonsDesign() {
        for button in dayButtons {
            updateDesignOfButton(button)
            setupButtonLayer(button)
        }
        setNeedsLayout()
    }
    
    fileprivate func updateDesignOfButton(_ button: UIButton) {
        let color = button.isSelected ? UIColor.purpleRed().cgColor : UIColor.lightGray().cgColor
        button.layer.borderColor = color
    }
    
    fileprivate func setupButtonLayer(_ button: UIButton) {
        button.layer.cornerRadius = Constants.defaultButtonWidth / 2
        button.layer.borderWidth = 1
    }
    
    fileprivate func resetSelectedDays() {
        selectedDays.removeAll(keepingCapacity: false)

        for button in dayButtons {
            if button.isSelected {
                selectedDays.insert(daysAvailableToSelect[button.tag].rawValue)
            }
        }
    }
    
    fileprivate func updateSelectedListWithButton(_ button: UIButton) {
        let selectedWeekday = daysAvailableToSelect[button.tag]
        if button.isSelected {
            selectedDays.remove(selectedWeekday.rawValue)
        } else {
            selectedDays.insert(selectedWeekday.rawValue)
        }
        
        button.isSelected = !button.isSelected
        let weekdays = weekdaysFromSelectedDays(selectedDays)
        selectedBasis = Basis.basisFromWeekdays(weekdays)
        sendActions(for: .valueChanged)
    }
    
    fileprivate func setupButtonsForSelectedDays(_ days: [Int]) {
        let weekdays = Set(weekdaysFromSelectedDays(Set(days)))
        let selectedDayNames = weekdays.map { (weekday) -> String in
            return weekday.shortName
        }
        
        for button in dayButtons {
            if let title = button.titleLabel?.text , selectedDayNames.contains(title) {
                button.isSelected = true
            }
        }
    }
    
    fileprivate func weekdaysFromSelectedDays(_ days: Set<Int>) -> [Weekday] {
        var weekdays: [Weekday] = []
        for day in days {
            if let weekday = Weekday(rawValue: day) {
                weekdays.append(weekday)
            }
        }
        return weekdays
    }
}
