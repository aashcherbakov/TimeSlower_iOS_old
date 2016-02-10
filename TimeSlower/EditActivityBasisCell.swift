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
    
    private var disposableBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupEvents()
    }
    
    private func setupEvents() {
        basisSelector.selectedSegmentIndex
            .subscribeNext { [weak self] (index) -> Void in
                if let index = index {
                    self?.daySelector.basis = ActivityBasis(rawValue: index)
                }
            }
            .addDisposableTo(disposableBag)
    }
}
