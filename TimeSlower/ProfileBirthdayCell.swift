//
//  ProfileBirthdayCell.swift
//  TimeSlower
//
//  Created by Alexander Shcherbakov on 10/1/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import UIKit
import TimeSlowerKit

/// ProfileEditingCell that displays date picker and TextfieldView
class ProfileBirthdayCell: UITableViewCell, ProfileEditingCell {
   
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var textfieldView: TextfieldView!
    @IBOutlet weak var textfieldViewHeight: NSLayoutConstraint!
    
    private let dateFormatter = StaticDateFormatter.fullDateFormatter
    
    weak var delegate: ProfileEditingCellDelegate?
    
    func setDefaultValue() {
        if textfieldView.text.value == nil {
            textfieldView.setText(dateFormatter.string(from: datePicker.date))
        }
    }
    
    func saveValue() {
        let date = dateFormatter.string(from: datePicker.date)
        delegate?.profileEditingCellDidUpdateValue(value: date, type: .Birthday)
    }
    
    @IBAction func didSelectDate(_ sender: UIDatePicker) {
        let date = dateFormatter.string(from: sender.date)
        textfieldView.setText(date)
        delegate?.profileEditingCellDidUpdateValue(value: date, type: .Birthday)
    }
    
}

