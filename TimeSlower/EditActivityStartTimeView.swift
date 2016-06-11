//
//  EditActivityStartTimeView.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 2/21/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/// UITableViewCell subclass to edit start time of activity
class EditActivityStartTimeView: UIView, ExpandableView {
    
    // MARK: - Properties
    
    @IBOutlet weak var view: UIView!
    
    @IBOutlet weak var textfieldView: TextfieldView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var separatorLineHeight: NSLayoutConstraint!
    @IBOutlet weak var textfieldViewHeightConstraint: NSLayoutConstraint!
    
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
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupXib()
        
        setupDesign()
        setupEvents()
    }
    
    func setupXib() {
        NSBundle.mainBundle().loadNibNamed(EditActivityStartTimeView.className, owner: self, options: nil)
        bounds = view.bounds
        addSubview(view)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        expanded.value = !expanded.value
        datePicker.alpha = expanded.value ? 1 : 0
        if expanded.value == true && selectedDate.value == nil {
            selectedDate.value = datePicker.date
            textfieldView.setText(shortDateFormatter.stringFromDate(datePicker.date))
        }
    }
    
    // MARK: - Setup Methods
    
    private func setupDesign() {
        textfieldView.setupWithConfig(StartTimeTextfield())
        separatorLineHeight.constant = kDefaultSeparatorHeight
    }
    
    private func setupEvents() {
        datePicker.rx_date
            .subscribeNext { [weak self] (date) -> Void in
                if self?.selectedDate.value != nil {
                    self?.selectedDate.value = date
                    self?.textfieldView.setText(self?.shortDateFormatter.stringFromDate(date))
                }
            }
            .addDisposableTo(disposableBag)
        
        selectedDate.subscribeNext { [weak self] (date) in
            guard let date = date else {
                return
            }
            
            self?.textfieldView.setText(self?.shortDateFormatter.stringFromDate(date))
        }.addDisposableTo(disposableBag)
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