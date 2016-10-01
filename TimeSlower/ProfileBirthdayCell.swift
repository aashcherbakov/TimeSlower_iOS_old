//
//  ProfileBirthdayCell.swift
//  TimeSlower
//
//  Created by Alexander Shcherbakov on 10/1/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import UIKit

/// ProfileEditingCell that displays date picker and TextfieldView
class ProfileBirthdayCell: UITableViewCell, ProfileEditingCell {
   
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var textfieldView: TextfieldView!
    @IBOutlet weak var textfieldViewHeight: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
