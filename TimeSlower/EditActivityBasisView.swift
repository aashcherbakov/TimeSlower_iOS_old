//
//  EditActivityBasisView.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 2/20/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import UIKit
import ReactiveCocoa
import TimeSlowerKit

/**
 UITableViewCell subclass that allows user to select activity basis.
 Includes BasisSelector and DaySelector instances.
 */
class EditActivityBasisView: UIControl {
    
    // MARK: - Properties
    
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var separatorLineHeight: NSLayoutConstraint!
    @IBOutlet weak var daySelector: DaySelector!
    @IBOutlet weak var basisSelector: BasisSelector!
    @IBOutlet weak var textFieldView: TextfieldView!
    @IBOutlet weak var textFieldViewHeightConstraint: NSLayoutConstraint!
    
    
    var selectedBasis: Basis? {
        didSet {
            if let selectedBasis = selectedBasis {
                daySelector.selectedBasis = selectedBasis
            }
            
            textFieldView.setText(selectedBasis?.description())
        }
    }
    
    /// Value that is being tracked from EditActivityViewController
    dynamic var selectedValue: Set<Int>?
    
    // MARK: - Overridden Methods
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupXib()
        setupEvents()
        setupDesign()
    }
    
    func setupXib() {
        NSBundle.mainBundle().loadNibNamed(EditActivityBasisView.className, owner: self, options: nil)
        bounds = view.bounds
        addSubview(view)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        sendActionsForControlEvents(.TouchUpInside)
    }
    
    // MARK: - Setup Methods
    
    private func setupDesign() {
        textFieldView.setupWithConfig(BasisTextfield())
        separatorLineHeight.constant = kDefaultSeparatorHeight
    }
    
    private func setupEvents() {
        basisSelector.rac_signalForControlEvents(.ValueChanged).toSignalProducer()
            .startWithNext { [weak self] (value) in
                guard let selector = value as? BasisSelector else { return }
                self?.updateBasis(selector.selectedIndex)
        }
        
        daySelector.rac_signalForControlEvents(.ValueChanged).toSignalProducer()
            .startWithNext { [weak self] (value) in
                guard let selector = value as? DaySelector else { return }
                
                self?.basisSelector.updateSegmentedIndexForBasis(selector.selectedBasis)
                self?.selectedBasis = selector.selectedBasis
                self?.selectedValue = selector.selectedDays
        }
    }
    
    private func updateBasis(index: Int?) {
        guard let index = index else { return }
        if let newBasis = Basis(rawValue: index) where selectedBasis != newBasis {
            daySelector.selectedBasis = newBasis
            selectedBasis = newBasis
            textFieldView.setText(newBasis.description())
            
        }
        
    }
}