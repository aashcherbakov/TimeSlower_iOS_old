//
//  EditActivityStartTimeCell.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 2/10/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/// UITableViewCell subclass to edit start time of activity
class EditActivityStartTimeCell: UITableViewCell {

    // MARK: - Properties
    
    @IBOutlet weak var textfieldView: TextfieldView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var separatorLineHeight: NSLayoutConstraint!
    
    /// Selected date. Observable
    var selectedDate = Variable<NSDate?>(nil)
    
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
        setupDesign()
        setupEvents()
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        expanded.value = !expanded.value
        datePicker.alpha = expanded.value ? 1 : 0
        textfieldView.setText(shortDateFormatter.stringFromDate(datePicker.date))
    }
    
    // MARK: - Setup Methods
    
    private func setupDesign() {
        textfieldView.setup(withType: .StartTime, delegate: nil)
        separatorLineHeight.constant = kDefaultSeparatorHeight
    }
    
    private func setupEvents() {
        datePicker.rx_date
            .subscribeNext { [weak self] (date) -> Void in
                self?.selectedDate.value = date
                self?.textfieldView.setText(self?.shortDateFormatter.stringFromDate(date))
            }
            .addDisposableTo(disposableBag)
    }
    
    /// Should be a singleton -> refactor
    private var shortDateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSCalendar.currentCalendar().locale
        dateFormatter.timeStyle = .ShortStyle
        dateFormatter.dateStyle = .NoStyle
        return dateFormatter
    }()
}
