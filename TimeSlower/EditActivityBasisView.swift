//
//  EditActivityBasisView.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 2/20/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import TimeSlowerKit

/**
 UITableViewCell subclass that allows user to select activity basis.
 Includes BasisSelector and DaySelector instances.
 */
class EditActivityBasisView: UIControl, ExpandableView {
    
    // MARK: - Properties
    
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var separatorLineHeight: NSLayoutConstraint!
    @IBOutlet weak var daySelector: DaySelector!
    @IBOutlet weak var basisSelector: BasisSelector!
    @IBOutlet weak var textFieldView: TextfieldView!
    @IBOutlet weak var textFieldViewHeightConstraint: NSLayoutConstraint!
    
    
    /// Variable that represents activity basis. Observable
    var selectedBasis = Variable<Basis?>(.Random)
    var selectedDays = Set<Weekday>?()
    
    /**
     Bool to signal view model that height of the cell should be recalculated.
     View model subscribes to this property and based on it's value changes the in State Machine.
     Observable.
     */
    var expanded = Variable<Bool>(false)
    
    private var disposableBag = DisposeBag()
    
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
        expanded.value = true
        
        if selectedBasis.value == nil {
            selectedBasis.value = .Workdays
        }
        
        sendActionsForControlEvents(.TouchUpInside)
    }
    
    // MARK: - Setup Methods
    
    private func setupDesign() {
        textFieldView.setupWithConfig(BasisTextfield())
        separatorLineHeight.constant = kDefaultSeparatorHeight
    }
    
    private func setupEvents() {
        basisSelector.selectedSegmentIndex.subscribeNext { [weak self] (index) -> Void in
                guard let index = index else {
                    return
                }
                
                self?.updateBasis(index)
            }.addDisposableTo(disposableBag)
        
        selectedBasis.subscribeNext { [weak self] (basis) in
            guard let basis = basis else {
                return
            }
            
            self?.daySelector.basis = basis
            self?.selectedDays = self?.daySelector.selectedDays
            self?.textFieldView.setText(basis.description())
            
        }.addDisposableTo(disposableBag)
        
        daySelector.selectedBasis.subscribeNext { [weak self] (basis) in
            guard let basis = basis else {
                return
            }
            
            self?.basisSelector.updateSegmentedIndexForBasis(basis)
            self?.selectedBasis.value = basis
            self?.selectedDays = self?.daySelector.selectedDays
        }.addDisposableTo(disposableBag)
        
    }
    
    private func updateBasis(index: Int) {
        let newBasis = Basis(rawValue: index)
        if selectedBasis.value != newBasis {
            daySelector.basis = newBasis
            selectedBasis.value = newBasis
            textFieldView.setText(newBasis?.description())
        }
    }
}