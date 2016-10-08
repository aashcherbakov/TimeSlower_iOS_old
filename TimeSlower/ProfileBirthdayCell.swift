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
    
    weak var delegate: ProfileEditingCellDelegate?
    
    @IBAction func didSelectDate(_ sender: UIDatePicker) {
        let date = StaticDateFormatter.shortDateAndTimeFormatter.string(from: sender.date)
        
        delegate?.profileEditingCellDidUpdateValue(value: date, type: .Birthday)
        textfieldView.setText(date)
    }
    
}

