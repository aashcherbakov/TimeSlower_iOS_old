//
//  DaySelector.swift
//  TimeSlower2
//
//  Created by Oleksandr Shcherbakov on 8/5/15.
//  Copyright (c) 2015 1lastDay. All rights reserved.
//

import UIKit
import TimeSlowerKit
import RxSwift

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
    
    private var daysAvailableToSelect: [Weekday] = [.First, .Second, .Third, .Forth, .Fifth, .Sixth, .Seventh]
    
    /// Set of days in format "Mon" "Fri" etc
    private(set) var selectedDays = Set<Weekday>()
    
    /// Basis that comes out of selected days
    private(set) var selectedBasis = Variable<ActivityBasis?>(nil)

    /// Activity Basis, used to display proper days
    var basis: ActivityBasis! {
        didSet {
            setupButtons()
        }
    }
    
    // MARK: - Overridden Methods
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupDesign()
    }

    
    // MARK: - Setup Methods
    
    private func setupDesign() {
        setupXib()
        setupInitialButtonsDesign()
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
    
    private func setupButtons() {
        setProperButtonsNames()
        updateButtonsDesign()
        resetSelectedDays()
        setNeedsLayout()
    }
    
    private func setProperButtonsNames() {        
        let daysForBasis = Weekday.weekdaysForBasis(basis)
        
        for button in dayButtons {
            let weekday = daysAvailableToSelect[button.tag]
            button.setTitle(weekday.shortName, forState: .Normal)
            
            if basis != .Random {
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
                selectedDays.insert(daysAvailableToSelect[button.tag])
            }
        }
    }
    
    private func updateSelectedListWithButton(button: UIButton) {
        let selectedWeekday = daysAvailableToSelect[button.tag]
        if button.selected {
            selectedDays.remove(selectedWeekday)
        } else {
            selectedDays.insert(selectedWeekday)
        }
        
        selectedBasis.value = DateManager.basisFromWeekdays(Array(selectedDays))
        button.selected = !button.selected
    }
    
}
