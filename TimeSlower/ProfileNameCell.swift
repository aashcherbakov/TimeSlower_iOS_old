//
//  ProfileNameCell.swift
//  TimeSlower
//
//  Created by Alexander Shcherbakov on 10/1/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import UIKit

/// ProfileEditingCell that displays TextfieldView. Implements UITextFiledDelegate
class ProfileNameCell: UITableViewCell, ProfileEditingCell {

    @IBOutlet weak var textfieldView: TextfieldView!
    @IBOutlet weak var textfieldViewHeight: NSLayoutConstraint!
    weak var delegate: ProfileEditingCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textfieldView.textField.delegate = self
        textfieldView.isUserInteractionEnabled = false
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        textfieldView.textField.becomeFirstResponder()
    }
}

// MARK: - UITextFieldDelegate
extension ProfileNameCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text, text.characters.count > 0 else {
            return false
        }
        
        delegate?.profileEditingCellDidUpdateValue(value: text, type: .Name)
        textfieldView.textField.resignFirstResponder()
        return true
    }
}
