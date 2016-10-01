//
//  ProfileNameCell.swift
//  TimeSlower
//
//  Created by Alexander Shcherbakov on 10/1/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import UIKit
import ReactiveSwift

/// ProfileEditingCell that displays TextfieldView. Implements UITextFiledDelegate
class ProfileNameCell: UITableViewCell, ProfileEditingCell {

    @IBOutlet weak var textfieldView: TextfieldView!
    @IBOutlet weak var textfieldViewHeight: NSLayoutConstraint!

    var selectedValue = MutableProperty<String?>(nil)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textfieldView.textField.delegate = self
    }
    
}

extension ProfileNameCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text, text.characters.count > 0 else {
            return false
        }
        
        selectedValue.value = text
        return true
    }
}
