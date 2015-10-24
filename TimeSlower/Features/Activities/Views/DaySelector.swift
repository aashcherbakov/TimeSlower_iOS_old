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
    
    @IBOutlet var dayButtons: [UIButton]!
    @IBOutlet var buttonsWidths: [NSLayoutConstraint]!
    @IBOutlet var view: UIView!
    
    @IBOutlet var twoLastButtonsWidths: [NSLayoutConstraint]!
    @IBOutlet var fiveLastButtonsWidths: [NSLayoutConstraint]!
    
    var basis: ActivityBasis! { didSet { basisToDisplay = BasisToDisplay(rawValue: basis.rawValue) } }
    var selectedDays = Set<String>()
    let kDefaultButtonWidth: CGFloat = 28
    
    
    private var daysAvailableToSelect = [String]()
    private var activeButtons: [UIButton]!
    private var basisToDisplay: BasisToDisplay! { didSet { setupButtons() } }
    
    //MARK: - Lifecycle
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupXib()
    }
    
    func setupXib() {
        NSBundle.mainBundle().loadNibNamed("DaySelector", owner: self, options: nil)
        bounds = view.bounds
        addSubview(view)
    }
    
    
    //MARK: - Setup buttons
    func setupButtons() {
        defineAvailableDayNames()
        prepareActiveButtons()
        setProperButtonsNames()
        selectedDays.removeAll(keepCapacity: false)
        setNeedsLayout()
    }
    
    func defineAvailableDayNames() {
        switch basisToDisplay! {
        case .Daily: daysAvailableToSelect = NSDateFormatter().shortWeekdaySymbols as [String]
        case .Workdays: daysAvailableToSelect = ["Mon", "Tue", "Wed", "Thu", "Fri"]
        case .Weekends: daysAvailableToSelect = ["Sat", "Sun"]
        }
    }
    
    func prepareActiveButtons() {
        activeButtons = dayButtons
        switch basisToDisplay! {
        case .Daily: break
        case .Workdays: activeButtons.removeRange(5...6)
        case .Weekends: activeButtons.removeRange(2...6)
        }
    }
    
    func setProperButtonsNames() {
        for button in activeButtons {
            button.setTitle(daysAvailableToSelect[button.tag], forState: .Normal)
            daySelected(button)
            setupButtonLayer(button)
        }
    }
    
    func setupButtonLayer(button: UIButton) {
        button.layer.cornerRadius = button.bounds.height / 2
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.extraLightGray().CGColor
    }
    
    
    
    //MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        if let basis = basisToDisplay {
            layoutButtonWidthForBasis(basis)
        }
    }
    
    func layoutButtonWidthForBasis(basis: BasisToDisplay) {
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
    
    func restoreButtonWidths() {
        for width in buttonsWidths {
            width.constant = kDefaultButtonWidth
        }
    }
    

    //MARK: - Actions
    
    @IBAction func daySelected(sender: UIButton) {
        let selectedDayName = sender.titleLabel!.text!
        if sender.selected {
            selectedDays.remove(selectedDayName)
        } else {
            selectedDays.insert(selectedDayName)
        }
        
        sender.selected = !sender.selected
        sender.backgroundColor = sender.selected ? UIColor.lightGray() : UIColor.clearColor()
    }
    
    @IBAction func returnToBasisSelection() {
        sendActionsForControlEvents(UIControlEvents.TouchUpInside)
        for button in activeButtons {
            button.selected = false
            button.backgroundColor = UIColor.clearColor()
        }
        
        restoreButtonWidths()
        
    }

}
