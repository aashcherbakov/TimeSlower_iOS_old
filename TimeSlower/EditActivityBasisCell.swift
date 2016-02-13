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

    @IBOutlet weak var basisSelector: BasisSelector!
    @IBOutlet weak var daySelector: DaySelector!
    @IBOutlet weak var textfieldView: TextfieldView!
    @IBOutlet weak var separatorLineHeight: NSLayoutConstraint!
    
    var selectedBasis = Variable<ActivityBasis?>(nil)
    var expanded = Variable<Bool>(false)
    
    private var disposableBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupEvents()
        setupDesign()
    }
    
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
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        expanded.value = !expanded.value
        if basisSelector.selectedSegmentIndex.value == nil {
            basisSelector.selectedSegmentIndex.value = 0 // daily by default
        }
    }
}
