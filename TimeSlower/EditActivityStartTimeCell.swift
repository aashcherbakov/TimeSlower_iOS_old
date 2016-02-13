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

class EditActivityStartTimeCell: UITableViewCell {

    @IBOutlet weak var textfieldView: TextfieldView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var separatorLineHeight: NSLayoutConstraint!
    private var disposableBag = DisposeBag()
    var selectedDate = Variable<NSDate?>(nil)
    var expanded = Variable<Bool>(false)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupDesign()
        setupEvents()
    }
    
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
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        expanded.value = !expanded.value
        datePicker.alpha = expanded.value ? 1 : 0
        textfieldView.setText(shortDateFormatter.stringFromDate(datePicker.date))
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
