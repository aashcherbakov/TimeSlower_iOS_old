//
//  EditActivityBasisCell.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 2/7/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import UIKit
import RxSwift
import TimeSlowerKit

/**
 UITableViewCell subclass that allows user to select activity basis.
 Includes BasisSelector and DaySelector instances.
*/
class EditActivityBasisCell: UITableViewCell {

    // MARK: - Properties
    
    @IBOutlet weak var basisSelector: BasisSelector!
    @IBOutlet weak var daySelector: DaySelector!
    @IBOutlet weak var textfieldView: TextfieldView!
    @IBOutlet weak var separatorLineHeight: NSLayoutConstraint!
    
    /// Variable that represents activity basis. Observable
    var selectedBasis = Variable<ActivityBasis?>(nil)
    
    /**
     Bool to signal view model that height of the cell should be recalculated.
     View model subscribes to this property and based on it's value changes the in State Machine.
     Observable.
     */
    var expanded = Variable<Bool>(false)
    
    private var disposableBag = DisposeBag()
    
    // MARK: - Overridden Methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupEvents()
        setupDesign()
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        expanded.value = !expanded.value
        if basisSelector.selectedSegmentIndex.value == nil {
            basisSelector.selectedSegmentIndex.value = 0 // daily by default
        }
    }
    
    // MARK: - Setup Methods
    
    private func setupDesign() {
        textfieldView.setup(withType: .Basis, delegate: nil)
        separatorLineHeight.constant = kDefaultSeparatorHeight
    }
    
    private func setupEvents() {
        basisSelector.selectedSegmentIndex
            .subscribeNext { [weak self] (index) -> Void in
                if let index = index {
                    self?.daySelector.basis = ActivityBasis(rawValue: index)
                    if let text = self?.daySelector.basis?.description() {
                        self?.textfieldView.setText(text)
                    }
                }
            }
            .addDisposableTo(disposableBag)
    }
}
