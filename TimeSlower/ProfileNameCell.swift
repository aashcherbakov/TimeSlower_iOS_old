//
//  ProfileNameCell.swift
//  TimeSlower
//
//  Created by Alexander Shcherbakov on 10/1/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import UIKit
import ReactiveSwift

class ProfileNameCell: UITableViewCell, ProfileEditingCell {

    @IBOutlet weak var textfieldView: TextfieldView!
    
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
