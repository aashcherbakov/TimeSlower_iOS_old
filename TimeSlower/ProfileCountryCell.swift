//
//  ProfileCountryCell.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 10/1/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import UIKit

/// ProfileEditingCell that displays country picker and TextfieldView
class ProfileCountryCell: UITableViewCell, ProfileEditingCell {
   
    @IBOutlet weak var textfieldView: TextfieldView!
    @IBOutlet weak var countryPicker: CountryPicker!
    @IBOutlet weak var textfieldViewHeight: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
}
